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

unit u_AvailPicsDD;

interface

uses
  SysUtils,
  Classes,
  XMLIntf,
  XMLDoc,
  strutils,
  i_InetConfig,
  i_DownloadRequest,
  u_DownloadRequest,
  u_AvailPicsAbstract,
  u_BinaryDataByMemStream;

type
  TAvailPicsDD = class(TAvailPicsByKey)
  Private
   FLayerKey: string;
  public
    procedure AfterConstruction; override;

    function ContentType: String; override;

    function ParseResponse(const AStream: TMemoryStream): Integer; override;

    function GetRequest(const AInetConfig: IInetConfig): IDownloadRequest; override;

    property LayerKey: string read FLayerKey write FLayerKey;

  end;
  TAvailPicsDataDoorsID = (dd1=1, dd2=2, dd3=3, dd4=4, dd5=5 );
  TAvailPicsDataDoors = array [TAvailPicsDataDoorsID] of TAvailPicsDD;

procedure GenerateAvailPicsDD(var ADDs: TAvailPicsDataDoors;
                               const ATileInfoPtr: PAvailPicsTileInfo);

implementation

uses
  forms,
  xmldom,
  windows,
  i_BinaryData,
  i_Downloader,
  i_DownloadResult,
  i_NotifierOperation,
  i_DownloadResultFactory,
  u_GeoToStr,
  u_GlobalState,
  u_DownloaderHttp,
  u_NotifierOperation,
  u_DownloadResultFactory,
  u_ArchiveReadWriteFactory,
  u_TileRequestBuilderHelpers;

procedure GenerateAvailPicsDD(var ADDs: TAvailPicsDataDoors;
                               const ATileInfoPtr: PAvailPicsTileInfo);
var
  j: TAvailPicsDataDoorsID;
begin
  for j := Low(TAvailPicsDataDoorsID) to High(TAvailPicsDataDoorsID) do begin
    if (nil=ADDs[j]) then begin
      ADDs[j] := TAvailPicsDD.Create(ATileInfoPtr);
      case Ord(j) of
      1: ADDs[j].LayerKey :='c4453cc2-6e13-4a39-91ce-972e567a15d8'; // WorldView-1
      2: ADDs[j].LayerKey :='2f864ade-2820-4ddd-9a51-b1d2f4b66e18'; // WorldView-2
      3: ADDs[j].LayerKey :='1798eda6-9987-407e-8373-eb324d5b31fd'; // QuickBird
      4: ADDs[j].LayerKey :='cb547543-5619-464d-a0ee-4ff5ff2e7dab'; // GeoEye
      5: ADDs[j].LayerKey :='f8ff73f4-7632-4dda-b276-5dca821a8281'; // Ikonos
      else
         ADDs[j].LayerKey:='';
      end;
    end;
  end;
end;

{ TAvailPicsDD }

procedure TAvailPicsDD.AfterConstruction;
begin
  inherited;
  FDefaultKey := '';
end;

function TAvailPicsDD.ContentType: String;
begin
  Result := 'text/xml';
end;



function TAvailPicsDD.ParseResponse(const AStream: TMemoryStream): Integer;
var
  XMLDocument: TXMLDocument;
  Node, SubNode: IXMLNode;
  PlacemarkNode: IXMLNode;
  VDate: String;
  Vsource, V_uid: String;
  VposList : String;
  VAddResult: Boolean;
  i, j: integer;
  VParams: TStrings;
begin
  Result:=0;

  if (not Assigned(FTileInfoPtr.AddImageProc)) then
    Exit;

  if (nil=AStream) or (0=AStream.Size) then
    Exit;

  XMLDocument := TXMLDocument.Create(Application);
  XMLDocument.LoadFromStream(AStream);
  Node := XMLDocument.DocumentElement;
  Node := Node.ChildNodes[0];
  Node := Node.ChildNodes[0];
  Node := Node.ChildNodes[0];
    if (Node <> nil) and (Node.ChildNodes.Count > 0) then begin
      for i := 0 to Node.ChildNodes.Count - 1 do begin
        PlacemarkNode := Node.ChildNodes[i];
        if PlacemarkNode.NodeName = 'Product' then begin
        Vsource := PlacemarkNode.GetAttribute('name');
        V_uid := PlacemarkNode.GetAttribute('uid');

        PlacemarkNode := PlacemarkNode.ChildNodes.FindNode('Footprints');
        for j := 0 to PlacemarkNode.ChildNodes.Count - 1 do  begin
          SubNode := PlacemarkNode.ChildNodes[j];
          if subNode.nodename='Footprint' then begin
          try
            VParams:=nil;
            VParams:=TStringList.Create;
            VDate := copy(SubNode.GetAttribute('acq_date'),1,10);
            VDate[5] := DateSeparator;
            VDate[8] := DateSeparator;

            VposList := SubNode.GetAttribute('acq_date');
            VParams.Values['acq_date'] := VposList;

            VposList := SubNode.GetAttribute('name');
            VParams.Values['CatalogID'] := VposList;

            VposList := SubNode.GetAttribute('uid');
            VParams.Values['uid'] := VposList;

            VposList := SubNode.GetAttribute('cloud_cover');
            VParams.Values['cloud_cover'] := VposList;

            VParams.Values['Provider'] := 'www.datadoors.net';

            SubNode := SubNode.ChildNodes.FindNode('Geometry');
            VposList := SubNode.text;
            VposList := ReplaceStr(VposList,',',' ');
            VposList := ReplaceStr(VposList,'(','');
            VposList := ReplaceStr(VposList,')','');
            VposList := ReplaceStr(VposList,'MULTIPOLYGON','');
            VParams.Values['Geometry'] := VposList;
            VParams.Values['Source'] := Vsource;
            VParams.Values['Source:uid'] := V_uid;

            VposList := ReplaceStr(Vsource,'DigitalGlobe ','');
            VposList := ReplaceStr(VposList,'GeoEye ','');
            VposList := 'DD:' + VposList;

            VAddResult := FTileInfoPtr.AddImageProc(Self, VDate, VposList, VParams);
            FreeAndNil(VParams);
            if VAddResult then begin
              Inc(Result);
            end;
           except
            if (nil<>VParams) then begin
              try
                VParams.Free;
              except
              end;
              VParams:=nil;
            end;
          end;
      end;
     end;
    end;
   end;
  end;
 end;

function TAvailPicsDD.GetRequest(const AInetConfig: IInetConfig): IDownloadRequest;
var
  VPostData: IBinaryData;
  VPostdataStr: string;
  VHttpData: string;
  VDownloader: IDownloader; // TDownloaderHttp;
  VPostRequest : IDownloadPostRequest; // POST
  VHeader: string;
  VLink: string;
  VStrPostData: AnsiString;
  VResultOk: IDownloadResultOk;
  VResult: IDownloadResult;
  VResultFactory: IDownloadResultFactory;
  VCancelNotifier: INotifierOperation;
  VResultWithRespond: IDownloadResultWithServerRespond;
  V_user_guest_uid: string;
//  V_streaming_uid: string;
  V_UserTokenUid: string;

begin
  VLink := 'http://www.datadoors.net/webservices/datadoors26.asmx';
  VHeader :='User-Agent: Opera/9.80 (Windows NT 6.1; U; ru) Presto/2.10.289 Version/12.01'+#$D#$A+
    'Host: www.datadoors.net'+#$D#$A+
    'Accept: text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1'+#$D#$A+
    'Accept-Language: ru-RU,ru;q=0.9,en;q=0.8'+#$D#$A+
    'Referer: http://www.datadoors.net/DataDoorsWeb/I3FlexClient/I3FlexClient.swf?rev=18'+#$D#$A+
    'Connection: Keep-Alive'+#$D#$A+
    'Content-type: text/xml; charset=utf-8'+#$D#$A+
    'SOAPAction: "http://www.datadoors.net/services/2.6/ApplicationParameters"';
  VStrPostData :=
    '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+#$D#$A+
    '  <SOAP-ENV:Body>'+#$D#$A+
    '    <ApplicationParameters xmlns="http://www.datadoors.net/services/2.6/">'+#$D#$A+
    '      <Application>DDWC</Application>'+#$D#$A+
    '    </ApplicationParameters>'+#$D#$A+
    '  </SOAP-ENV:Body>'+#$D#$A+
    '</SOAP-ENV:Envelope>';
  VPostData :=
        TBinaryDataByMemStream.CreateFromMem(
          Length(VStrPostData),
          Addr(VStrPostData[1])
        );
  VPostRequest := TDownloadPostRequest.Create(
                   Vlink,
                   VHeader,
                   VPostData,
                   GState.InetConfig.GetStatic
                  );
  VResultFactory := TDownloadResultFactory.Create;
  VDownloader:=TDownloaderHttp.Create(VResultFactory);
  VCancelNotifier := TNotifierOperation.Create;
  VResult := VDownloader.DoRequest(
              VPostRequest,
              VCancelNotifier,
              VCancelNotifier.CurrentOperation
             );
  if Supports(VResult, IDownloadResultWithServerRespond, VResultWithRespond) then
   if Supports(VResult, IDownloadResultOk, VResultOk) then begin
     SetLength(VHttpData, VResultOk.Data.Size);
     Move(VResultOk.Data.Buffer^, VHttpData[1], VResultOk.Data.Size);
    end;
  V_user_guest_uid := GetBetween(VHttpData, 'key="user_guest_uid" value="', '"'); // 5794ce45-fd31-4591-b28c-0ace80b8db8b
//  V_streaming_uid  := GetBetween(VHttpData ,'key="streaming_uid" value="', '"'); // 3d834b43-99b4-4302-9e47-2438d096458f

  VStrPostData :=
    '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+#$D#$A+
    '  <SOAP-ENV:Body>'+#$D#$A+
    '    <AuthenticateGuest xmlns="http://www.datadoors.net/services/2.6/">'+#$D#$A+
    '      <guestUid>'+V_user_guest_uid+'</guestUid>'+#$D#$A+
    '      <application>DDWC</application>'+#$D#$A+
    '    </AuthenticateGuest>'+#$D#$A+
    '  </SOAP-ENV:Body>'+#$D#$A+
    '</SOAP-ENV:Envelope>';
  VPostData :=
        TBinaryDataByMemStream.CreateFromMem(
          Length(VStrPostData),
          Addr(VStrPostData[1])
        );
  VHeader :='User-Agent: Opera/9.80 (Windows NT 6.1; U; ru) Presto/2.10.289 Version/12.01'+#$D#$A+
    'Host: www.datadoors.net'+#$D#$A+
    'Accept: text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1'+#$D#$A+
    'Accept-Language: ru-RU,ru;q=0.9,en;q=0.8'+#$D#$A+
    'Referer: http://www.datadoors.net/DataDoorsWeb/I3FlexClient/I3FlexClient.swf?rev=18'+#$D#$A+
    'Connection: Keep-Alive'+#$D#$A+
    'Content-type: text/xml; charset=utf-8'+#$D#$A+
    'SOAPAction: "http://www.datadoors.net/services/2.6/AuthenticateGuest"';

  VLink := 'https://www.datadoors.net/webservices/auth26.asmx';
  VPostRequest := TDownloadPostRequest.Create(
                    Vlink,
                    VHeader,
                    VPostData,
                    GState.InetConfig.GetStatic
                  );
  VResult := VDownloader.DoRequest(
              VPostRequest,
              VCancelNotifier,
              VCancelNotifier.CurrentOperation
            );
  if Supports(VResult, IDownloadResultWithServerRespond, VResultWithRespond) then
   if Supports(VResult, IDownloadResultOk, VResultOk) then begin
     SetLength(VHttpData, VResultOk.Data.Size);
     Move(VResultOk.Data.Buffer^, VHttpData[1], VResultOk.Data.Size);
    end;
  V_UserTokenUid := GetBetween(VHttpData ,'<ResponseValue>', '</ResponseValue>');

  if length(V_UserTokenUid)=36 then
  VPostDataStr :='<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+#$D#$A+
    '  <SOAP-ENV:Header>'+#$D#$A+
    '    <tns:DdSoapHeader MyAttribute="" xmlns="http://www.datadoors.net/services/2.6/" xmlns:tns="http://www.datadoors.net/services/2.6/">'+#$D#$A+
    '      <UserTokenUid>'+V_UserTokenUid+'</UserTokenUid>'+#$D#$A+
    '      <ApplicationName>DDWC</ApplicationName>'+#$D#$A+
    '      <CultureName>en-US</CultureName>'+#$D#$A+
    '      <CurrencyCode>USD</CurrencyCode>'+#$D#$A+
    '      <IsAuthenticated>false</IsAuthenticated>'+#$D#$A+
    '    </tns:DdSoapHeader>'+#$D#$A+
    '  </SOAP-ENV:Header>'+#$D#$A+
    '  <SOAP-ENV:Body>'+#$D#$A+
    '    <GetProductFootprintsByCriteria xmlns="http://www.datadoors.net/services/2.6/">'+#$D#$A+
    '      <Criteria>'+#$D#$A+
    '        <UserUID>'+V_user_guest_uid+'</UserUID>'+#$D#$A+
    '        <ProductUID>'+LayerKey+'</ProductUID>'+#$D#$A+
    '        <AOI>MULTIPOLYGON((('+#$D#$A+
    RoundEx(FTileInfoPtr.TileRect.Left, 8)+' '+RoundEx(FTileInfoPtr.TileRect.Top, 8)+','+
    RoundEx(FTileInfoPtr.TileRect.Left, 8)+' '+RoundEx(FTileInfoPtr.TileRect.Bottom, 8)+','+
    RoundEx(FTileInfoPtr.TileRect.Right, 8)+' '+RoundEx(FTileInfoPtr.TileRect.Top, 8)+','+
    RoundEx(FTileInfoPtr.TileRect.Right, 8)+' '+RoundEx(FTileInfoPtr.TileRect.Bottom, 8)+','+
    RoundEx(FTileInfoPtr.TileRect.Left, 8)+' '+RoundEx(FTileInfoPtr.TileRect.Top, 8)+
    ')))</AOI>'+#$D#$A+
    '        <MetadataCriteria CloudCover="5" UnusableData="-1" IncidenceAngle="-1" SunAngle="-1" SnowCover="-1" Quality="-1" Accuracy="-1" RelevantLicensing="false"/>'+#$D#$A+
    '      </Criteria>'+#$D#$A+
    '    </GetProductFootprintsByCriteria>'+#$D#$A+
    '  </SOAP-ENV:Body>'+#$D#$A+
    '</SOAP-ENV:Envelope>'
  else VPostDataStr := '';



 VPostData :=
  TBinaryDataByMemStream.CreateFromMem(
     Length(VPostDataStr),
     Addr(VPostDataStr[1])
     );

 VHeader := 'Host: www.datadoors.net'+#$D#$A+
  'Accept: text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1'+#$D#$A+
  'Accept-Language: ru-RU,ru;q=0.9,en;q=0.8'+#$D#$A+
  'Referer: http://www.datadoors.net/DataDoorsWeb/I3FlexClient/I3FlexClient.swf?rev=18'+#$D#$A+
  'Connection: Keep-Alive'+#$D#$A+
  'Content-type: text/xml; charset=utf-8'+#$D#$A+
  'SOAPAction: "http://www.datadoors.net/services/2.6/GetProductFootprintsByCriteria"';

     Result := TDownloadPostRequest.Create(
              'http://www.datadoors.net/webservices/datadoors26.asmx',
              VHeader,
              VPostData,
              AInetConfig.GetStatic
               );
end;


end.
