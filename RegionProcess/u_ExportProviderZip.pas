unit u_ExportProviderZip;

interface

uses
  Controls,
  
  t_GeoTypes,
  i_LanguageManager,
  i_MapTypes,
  i_ActiveMapsConfig,
  i_MapTypeGUIConfigList,
  i_TileFileNameGeneratorsList,
  u_ExportProviderAbstract,
  fr_ExportToFileCont;

type
  TExportProviderZip = class(TExportProviderAbstract)
  private
    FFrame: TfrExportToFileCont;
    FTileNameGenerator: ITileFileNameGeneratorsList;
  public
    constructor Create(
      AParent: TWinControl;
      ALanguageManager: ILanguageManager;
      AMainMapsConfig: IMainMapsConfig;
      AFullMapsSet: IMapTypeSet;
      AGUIConfigList: IMapTypeGUIConfigList;
      ATileNameGenerator: ITileFileNameGeneratorsList
    );
    destructor Destroy; override;
    function GetCaption: string; override;
    procedure InitFrame(Azoom: byte; APolygon: TArrayOfDoublePoint); override;
    procedure Show; override;
    procedure Hide; override;
    procedure RefreshTranslation; override;
    procedure StartProcess(APolygon: TArrayOfDoublePoint); override;
  end;


implementation

uses
  SysUtils,
  i_TileFileNameGenerator,
  u_ThreadExportToZip,
  u_ResStrings,
  u_MapType;

{ TExportProviderKml }

constructor TExportProviderZip.Create(
  AParent: TWinControl;
  ALanguageManager: ILanguageManager;
  AMainMapsConfig: IMainMapsConfig;
  AFullMapsSet: IMapTypeSet;
  AGUIConfigList: IMapTypeGUIConfigList;
  ATileNameGenerator: ITileFileNameGeneratorsList
);
begin
  inherited Create(AParent, ALanguageManager, AMainMapsConfig, AFullMapsSet, AGUIConfigList);
  FTileNameGenerator := ATileNameGenerator;
end;

destructor TExportProviderZip.Destroy;
begin
  FreeAndNil(FFrame);
  inherited;
end;

function TExportProviderZip.GetCaption: string;
begin
  Result := SAS_STR_ExportZipPackCaption;
end;

procedure TExportProviderZip.InitFrame(Azoom: byte; APolygon: TArrayOfDoublePoint);
begin
  if FFrame = nil then begin
    FFrame := TfrExportToFileCont.CreateForFileType(
      nil,
      Self.MainMapsConfig,
      Self.FullMapsSet,
      Self.GUIConfigList,
      'Zip |*.zip',
      'zip'
    );
    FFrame.Visible := False;
    FFrame.Parent := Self.Parent;
  end;
  FFrame.Init;
end;

procedure TExportProviderZip.RefreshTranslation;
begin
  inherited;
  if FFrame <> nil then begin
    FFrame.RefreshTranslation;
  end;
end;

procedure TExportProviderZip.Hide;
begin
  inherited;
  if FFrame <> nil then begin
    if FFrame.Visible then begin
      FFrame.Hide;
    end;
  end;
end;

procedure TExportProviderZip.Show;
begin
  inherited;
  if FFrame <> nil then begin
    if not FFrame.Visible then begin
      FFrame.Show;
    end;
  end;
end;

procedure TExportProviderZip.StartProcess(APolygon: TArrayOfDoublePoint);
var
  i:integer;
  path:string;
  Zoomarr:array [0..23] of boolean;
  VMapType: TMapType;
  VNameGenerator: ITileFileNameGenerator;
begin
  inherited;
  for i:=0 to 23 do begin
    ZoomArr[i]:= FFrame.chklstZooms.Checked[i];
  end;
  VMapType:=TMapType(FFrame.cbbMap.Items.Objects[FFrame.cbbMap.ItemIndex]);
  path:=FFrame.edtTargetFile.Text;
  VNameGenerator := FTileNameGenerator.GetGenerator(FFrame.cbbNamesType.ItemIndex + 1);
  TThreadExportToZip.Create(path, APolygon, Zoomarr, VMapType, VNameGenerator);
end;

end.

