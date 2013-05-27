{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit u_GeoCoderByWikimapia;

interface

uses
  Classes,
  i_NotifierOperation,
  i_LocalCoordConverter,
  i_DownloadRequest,
  i_DownloadResult,
  u_GeoCoderBasic;

type
  TGeoCoderByWikiMapia = class(TGeoCoderBasic)
  protected
    function PrepareRequest(
      const ASearch: WideString;
      const ALocalConverter: ILocalCoordConverter
    ): IDownloadRequest; override;
    function ParseResultToPlacemarksList(
      const ACancelNotifier: INotifierOperation;
      AOperationID: Integer;
      const AResult: IDownloadResultOk;
      const ASearch: WideString;
      const ALocalConverter: ILocalCoordConverter
    ): IInterfaceList; override;
  public
  end;

implementation

uses
  SysUtils,
  StrUtils,
  t_GeoTypes,
  i_GeoCoder,
  i_CoordConverter,
  u_ResStrings,
  u_GeoCodePlacemark;


{ TGeoCoderByWikiMapia }


function TGeoCoderByWikiMapia.ParseResultToPlacemarksList(
  const ACancelNotifier: INotifierOperation;
  AOperationID: Integer;
  const AResult: IDownloadResultOk;
  const ASearch: WideString;
  const ALocalConverter: ILocalCoordConverter
): IInterfaceList;
var
  slat, slon, sname, sdesc, sfulldesc{, vzoom}: string;
  i, j: integer;
  VPoint: TDoublePoint;
  VPlace: IGeoCodePlacemark;
  VList: IInterfaceList;
  VFormatSettings: TFormatSettings;
  VStr: string;
begin
  sfulldesc := '';
  sdesc := '';
  if AResult.Data.Size <= 0 then begin
    raise EParserError.Create(SAS_ERR_EmptyServerResponse);
  end;

  SetLength(Vstr, AResult.Data.Size);
  Move(AResult.Data.Buffer^, Vstr[1], AResult.Data.Size);
  VFormatSettings.DecimalSeparator := '.';
  VList := TInterfaceList.Create;
  i := PosEx('<ul class="nav searchlist">', VStr, 1);
  while (PosEx('<li onclick="parent.Search.zoomTo', VStr, i) > i) and (i > 0) do begin
    j := i;

    //    ��� ��� ������� ������ �������� ��� �����
    //    i := PosEx('parent.zoom_from_inf(', AStr, j);
    //    i := PosEx(',', AStr, i);
    //    i := PosEx(',', AStr, i);
    //    j := PosEx(')', AStr, i);
    //    VZoom:=Copy(AStr, i + 1, j - (i + 1));

    i := PosEx('parent.Search.zoomTo(', VStr, j);
    j := PosEx(',', VStr, i + 21);
    slon := Copy(VStr, i + 21, j - (i + 21));

    i := j;
    j := PosEx(',', VStr, i + 1);
    slat := Copy(VStr, i + 1, j - (i + 1));

    i := PosEx('<strong>', VStr, j);
    j := PosEx('</strong>', VStr, i + 8);
    sname := Utf8ToAnsi(Copy(VStr, i + 8, j - (i + 8)));

    i := PosEx('<small>', VStr, j);
    j := PosEx('<', VStr, i + 7);
    sdesc := Utf8ToAnsi(Copy(VStr, i + 7, j - (i + 7)));
    sdesc := Trim(ReplaceStr(sdesc,#$0A,''));

    //    ������� �� ������ �����
    //    sfulldesc:='http://www.wikimapia.org/#lat='+slat+'&lon='+slon+'&z='+VZoom;

    try
      VPoint.Y := StrToFloat(slat, VFormatSettings);
      VPoint.X := StrToFloat(slon, VFormatSettings);
    except
      raise EParserError.CreateFmt(SAS_ERR_CoordParseError, [slat, slon]);
    end;

    if not ((slat = '0') or (slon = '0')) then begin // ���������� ����� ��� ���������
      VPlace := TGeoCodePlacemark.Create(VPoint, sname, sdesc, sfulldesc, 4);
      VList.Add(VPlace);
    end;

  end;
  if VList.GetCount>1 then SortIt(VList, ALocalConverter);
  Result := VList;
end;

function TGeoCoderByWikiMapia.PrepareRequest(
  const ASearch: WideString;
  const ALocalConverter: ILocalCoordConverter
): IDownloadRequest;
var
  VSearch: String;
  VConverter: ICoordConverter;
  VZoom: Byte;
  VMapRect: TDoubleRect;
  VLonLatRect: TDoubleRect;
begin

  VSearch := ASearch;
  VConverter := ALocalConverter.GetGeoConverter;
  VZoom := ALocalConverter.GetZoom;
  VMapRect := ALocalConverter.GetRectInMapPixelFloat;
  VConverter.CheckPixelRectFloat(VMapRect, VZoom);
  VLonLatRect := VConverter.PixelRectFloat2LonLatRect(VMapRect, VZoom);

  //http://wikimapia.org/search/?q=%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B4%D0%B0%D1%80
  Result :=
    PrepareRequestByURL(
      'http://wikimapia.org/search/?q=' + URLEncode(AnsiToUtf8(VSearch))
    );
end;

end.
