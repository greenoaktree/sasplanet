unit fr_MapCombine;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  CheckLst,
  Spin,
  u_CommonFormAndFrameParents,
  t_GeoTypes;

type
  TfrMapCombine = class(TFrame)
    cbbHybr: TComboBox;
    grpSplit: TGroupBox;
    lblSplitHor: TLabel;
    lblSplitVert: TLabel;
    seSplitHor: TSpinEdit;
    seSplitVert: TSpinEdit;
    seJpgQuality: TSpinEdit;
    chkUseMapMarks: TCheckBox;
    chklstPrTypes: TCheckListBox;
    chkUseRecolor: TCheckBox;
    cbbMap: TComboBox;
    lblJpgQulity: TLabel;
    lblMap: TLabel;
    lblHybr: TLabel;
    lblPrTypes: TLabel;
    pnlTop: TPanel;
    pnlTargetFile: TPanel;
    lblTargetFile: TLabel;
    edtTargetFile: TEdit;
    btnSelectTargetFile: TButton;
    pnlOutputFormat: TPanel;
    cbbOutputFormat: TComboBox;
    lblOutputFormat: TLabel;
    pnlBottom: TPanel;
    pnlRight: TPanel;
    pnlCenter: TPanel;
    dlgSaveTargetFile: TSaveDialog;
    cbbZoom: TComboBox;
    lblZoom: TLabel;
    lblStat: TLabel;
    flwpnlJpegQuality: TFlowPanel;
    procedure cbbOutputFormatChange(Sender: TObject);
    procedure cbbZoomChange(Sender: TObject);
    procedure btnSelectTargetFileClick(Sender: TObject);
  private
    FPolygLL: TExtendedPointArray;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshTranslation; override;
    procedure Init(AZoom: Byte; APolygLL: TExtendedPointArray);
  end;

implementation

uses
  i_IMapCalibration,
  u_GlobalState,
  UGeoFun,
  UResStrings,
  UMapType;

{$R *.dfm}

{ TfrMapCombine }

procedure TfrMapCombine.btnSelectTargetFileClick(Sender: TObject);
begin
  if dlgSaveTargetFile.Execute then begin
    edtTargetFile.Text := dlgSaveTargetFile.FileName;
  end;
end;

procedure TfrMapCombine.cbbOutputFormatChange(Sender: TObject);
var
  VNewExt: string;
  VFileName: string;
begin
  case cbbOutputFormat.ItemIndex of
    0: VNewExt := 'ecw';
    1: VNewExt := 'bmp';
    2: VNewExt := 'kmz';
    3: VNewExt := 'jpg';
    4: VNewExt := 'jp2';
  else
    VNewExt := '';
  end;
  VFileName := edtTargetFile.Text;
  if VFileName <> '' then begin
    VFileName := ChangeFileExt(VFileName, '.' + VNewExt);
  end;
  edtTargetFile.Text := VFileName;
  dlgSaveTargetFile.DefaultExt := VNewExt;
  dlgSaveTargetFile.Filter := cbbOutputFormat.Items[cbbOutputFormat.ItemIndex] + ' | *.' + VNewExt;
end;

procedure TfrMapCombine.cbbZoomChange(Sender: TObject);
var
  polyg:TPointArray;
  min,max:TPoint;
  numd:int64 ;
  Vmt: TMapType;
  VZoom: byte;
begin
  Vmt := TMapType(cbbMap.Items.Objects[cbbMap.ItemIndex]);
  VZoom := cbbZoom.ItemIndex;
  polyg := Vmt.GeoConvert.LonLatArray2PixelArray(FPolygLL, VZoom);
  numd:=GetDwnlNum(min,max,polyg,true);
  lblStat.Caption:=SAS_STR_filesnum+': '+inttostr((max.x-min.x)div 256+1)+'x'
                  +inttostr((max.y-min.y)div 256+1)+'('+inttostr(numd)+')';
  GetMinMax(min,max,polyg,false);
  lblStat.Caption:=lblStat.Caption+', '+SAS_STR_Resolution+' '+inttostr(max.x-min.x)+'x'
                +inttostr(max.y-min.y);
end;

constructor TfrMapCombine.Create(AOwner: TComponent);
begin
  inherited;
  cbbOutputFormat.ItemIndex := 0;
end;

procedure TfrMapCombine.Init(AZoom: Byte; APolygLL: TExtendedPointArray);
var
  i: Integer;
  VMapType: TMapType;
  VActiveMap: TMapType;
  VAddedIndex: Integer;
  VMapCalibration: IMapCalibration;
begin
  FPolygLL := APolygLL;
  cbbZoom.Items.Clear;
  for i:=1 to 24 do begin
    cbbZoom.Items.Add(inttostr(i));
  end;
  cbbZoom.ItemIndex := AZoom;

  VActiveMap := GState.ViewState.GetCurrentMap;
  cbbMap.Items.Clear;
  cbbHybr.Items.Clear;
  cbbHybr.Items.Add(SAS_STR_No);
  For i:=0 to length(GState.MapType)-1 do begin
    VMapType := GState.MapType[i];
    if VMapType.UseStick and VMapType.IsBitmapTiles then begin
      if not VMapType.asLayer then begin
        VAddedIndex := cbbMap.Items.AddObject(VMapType.name,VMapType);
        if VMapType = VActiveMap then begin
          cbbMap.ItemIndex:=VAddedIndex;
        end;
      end else begin
        VAddedIndex := cbbHybr.Items.AddObject(VMapType.name,VMapType);
        if (cbbHybr.ItemIndex=-1) then begin
          if GState.ViewState.IsHybrGUIDSelected(VMapType.GUID) then begin
            cbbHybr.ItemIndex:=VAddedIndex;
          end;
        end;
      end;
    end;
  end;
  if (cbbMap.Items.Count > 0) and (cbbMap.ItemIndex < 0) then begin
    cbbMap.ItemIndex := 0;
  end;
  if (cbbHybr.Items.Count > 0) and (cbbHybr.ItemIndex < 0) then begin
    cbbHybr.ItemIndex := 0;
  end;

  chklstPrTypes.Clear;
  GState.MapCalibrationList.Lock;
  try
    for i := 0 to GState.MapCalibrationList.Count - 1 do begin
      VMapCalibration := GState.MapCalibrationList.Get(i) as IMapCalibration;
      chklstPrTypes.AddItem(VMapCalibration.GetName, Pointer(VMapCalibration));
    end;
  finally
    GState.MapCalibrationList.Unlock;
  end;
  cbbOutputFormatChange(cbbOutputFormat);
end;

procedure TfrMapCombine.RefreshTranslation;
var
  i: Integer;
begin
  i := cbbOutputFormat.ItemIndex;
  inherited;
  cbbOutputFormat.ItemIndex := i;
end;

end.
