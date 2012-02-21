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

unit u_ProviderTilesDownload;

interface

uses
  Windows, // for inline AnsiSameText
  Controls,
  i_JclNotify,
  i_MapTypes,
  i_VectorItemLonLat,
  i_VectorItmesFactory,
  i_CoordConverterFactory,
  i_LanguageManager,
  i_ActiveMapsConfig,
  i_MapTypeGUIConfigList,
  i_ValueToStringConverter,
  i_GlobalDownloadConfig,
  i_DownloadInfoSimple,
  u_MapType,
  u_ExportProviderAbstract,
  fr_TilesDownload;

type
  TProviderTilesDownload = class(TExportProviderAbstract)
  private
    FFrame: TfrTilesDownload;
    FAppClosingNotifier: IJclNotifier;
    FValueToStringConverterConfig: IValueToStringConverterConfig;
    FDownloadConfig: IGlobalDownloadConfig;
    FDownloadInfo: IDownloadInfoSimple;
    FProjectionFactory: IProjectionInfoFactory;
    FVectorItmesFactory: IVectorItmesFactory;
  public
    constructor Create(
      AParent: TWinControl;
      AAppClosingNotifier: IJclNotifier;
      ALanguageManager: ILanguageManager;
      AValueToStringConverterConfig: IValueToStringConverterConfig;
      AMainMapsConfig: IMainMapsConfig;
      AFullMapsSet: IMapTypeSet;
      AGUIConfigList: IMapTypeGUIConfigList;
      AProjectionFactory: IProjectionInfoFactory;
      AVectorItmesFactory: IVectorItmesFactory;
      ADownloadConfig: IGlobalDownloadConfig;
      ADownloadInfo: IDownloadInfoSimple
    );
    destructor Destroy; override;
    function GetCaption: string; override;
    procedure InitFrame(Azoom: byte; APolygon: ILonLatPolygon); override;
    procedure Show; override;
    procedure Hide; override;
    procedure RefreshTranslation; override;
    procedure StartProcess(APolygon: ILonLatPolygon); override;
    procedure StartBySLS(AFileName: string);
  end;


implementation

uses
  SysUtils,
  IniFiles,
  i_LogSimple,
  i_LogForTaskThread,
  i_VectorItemProjected,
  i_ConfigDataProvider,
  u_ConfigDataProviderByIniFile,
  u_LogForTaskThread,
  u_ThreadDownloadTiles,
  frm_ProgressDownload,
  u_ResStrings;

{ TProviderTilesDownload }

constructor TProviderTilesDownload.Create(
  AParent: TWinControl;
  AAppClosingNotifier: IJclNotifier;
  ALanguageManager: ILanguageManager;
  AValueToStringConverterConfig: IValueToStringConverterConfig;
  AMainMapsConfig: IMainMapsConfig;
  AFullMapsSet: IMapTypeSet;
  AGUIConfigList: IMapTypeGUIConfigList;
  AProjectionFactory: IProjectionInfoFactory;
  AVectorItmesFactory: IVectorItmesFactory;
  ADownloadConfig: IGlobalDownloadConfig;
  ADownloadInfo: IDownloadInfoSimple
);
begin
  inherited Create(AParent, ALanguageManager, AMainMapsConfig, AFullMapsSet, AGUIConfigList);
  FAppClosingNotifier := AAppClosingNotifier;
  FValueToStringConverterConfig := AValueToStringConverterConfig;
  FProjectionFactory := AProjectionFactory;
  FVectorItmesFactory := AVectorItmesFactory;
  FDownloadConfig := ADownloadConfig;
  FDownloadInfo := ADownloadInfo;
end;

destructor TProviderTilesDownload.Destroy;
begin
  FreeAndNil(FFrame);
  inherited;
end;

function TProviderTilesDownload.GetCaption: string;
begin
  Result := SAS_STR_OperationDownloadCaption;
end;

procedure TProviderTilesDownload.InitFrame(Azoom: byte; APolygon: ILonLatPolygon);
begin
  if FFrame = nil then begin
    FFrame := TfrTilesDownload.Create(
      nil,
      FProjectionFactory,
      FVectorItmesFactory,
      Self.MainMapsConfig,
      Self.FullMapsSet,
      Self.GUIConfigList
    );
    FFrame.Visible := False;
    FFrame.Parent := Self.Parent;
  end;
  FFrame.Init(Azoom, APolygon);
end;

procedure TProviderTilesDownload.RefreshTranslation;
begin
  inherited;
  if FFrame <> nil then begin
    FFrame.RefreshTranslation;
  end;
end;

procedure TProviderTilesDownload.Hide;
begin
  inherited;
  if FFrame <> nil then begin
    if FFrame.Visible then begin
      FFrame.Hide;
    end;
  end;
end;

procedure TProviderTilesDownload.Show;
begin
  inherited;
  if FFrame <> nil then begin
    if not FFrame.Visible then begin
      FFrame.Show;
    end;
  end;
end;

procedure TProviderTilesDownload.StartBySLS(AFileName: string);
var
  VIni: TMemIniFile;
  VSLSData: IConfigDataProvider;
  VSessionSection: IConfigDataProvider;
  VLog: TLogForTaskThread;
  VSimpleLog: ILogSimple;
  VThreadLog:ILogForTaskThread;
  VThread: TThreadDownloadTiles;
begin
  VIni := TMemIniFile.Create(AFileName);
  VSLSData := TConfigDataProviderByIniFile.Create(VIni);
  VSessionSection := VSLSData.GetSubItem('Session');
  VLog := TLogForTaskThread.Create(5000, 0);
  VSimpleLog := VLog;
  VThreadLog := VLog;
  VThread :=
    TThreadDownloadTiles.CreateFromSls(
      FAppClosingNotifier,
      FVectorItmesFactory,
      VSimpleLog,
      FullMapsSet,
      FProjectionFactory,
      VSessionSection,
      FDownloadConfig,
      FDownloadInfo
    );
  TfrmProgressDownload.Create(
    LanguageManager,
    FValueToStringConverterConfig,
    VThread,
    VThreadLog
  );
end;

procedure TProviderTilesDownload.StartProcess(APolygon: ILonLatPolygon);
var
  VMapType: TMapType;
  VZoom: byte;
  VLog: TLogForTaskThread;
  VSimpleLog: ILogSimple;
  VThreadLog: ILogForTaskThread;
  VThread: TThreadDownloadTiles;
  VProjectedPolygon: IProjectedPolygon;
  VForAttachments: Boolean;
begin
  VMapType:=TMapType(FFrame.cbbMap.Items.Objects[FFrame.cbbMap.ItemIndex]);
  VForAttachments:=(not AnsiSameText(FFrame.cbbMap.Items[FFrame.cbbMap.ItemIndex],VMapType.GUIConfig.Name.Value));
  VZoom := FFrame.cbbZoom.ItemIndex;

  VProjectedPolygon :=
    FVectorItmesFactory.CreateProjectedPolygonByLonLatPolygon(
      FProjectionFactory.GetByConverterAndZoom(
        VMapType.GeoConvert,
        VZoom
      ),
      APolygon
    );
  VLog := TLogForTaskThread.Create(5000, 0);
  VSimpleLog := VLog;
  VThreadLog := VLog;
  VThread := TThreadDownloadTiles.Create(
    FAppClosingNotifier,
    VSimpleLog,
    APolygon,
    VProjectedPolygon,
    FDownloadConfig,
    FDownloadInfo,
    FFrame.chkReplace.Checked,
    FFrame.chkReplaceIfDifSize.Checked,
    FFrame.chkReplaceOlder.Checked,
    FFrame.chkTryLoadIfTNE.Checked,
    VZoom,
    VMapType,
    FFrame.dtpReplaceOlderDate.DateTime,
    VForAttachments
  );
  TfrmProgressDownload.Create(
    Self.LanguageManager,
    FValueToStringConverterConfig,
    VThread,
    VThreadLog
  );
end;

end.

