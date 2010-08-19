unit UImport;

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
  DB,
  Dialogs,
  StdCtrls,
  Spin,
  ExtCtrls,
  Buttons,
  GR32,
  GR32_Resamplers,
  Unit1,
  UMarksExplorer,
  UPLT;

type
  TFImport = class(TForm)
    Label8: TLabel;
    CBKateg: TComboBox;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ColorBox1: TColorBox;
    SpinEdit1: TSpinEdit;
    ColorBox2: TColorBox;
    SpinEdit2: TSpinEdit;
    SEtransp: TSpinEdit;
    ComboBox1: TComboBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    ColorDialog1: TColorDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    SpeedButton3: TSpeedButton;
    ColorBox3: TColorBox;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    SpeedButton4: TSpeedButton;
    Label13: TLabel;
    Label14: TLabel;
    SpeedButton5: TSpeedButton;
    Label15: TLabel;
    Label16: TLabel;
    ColorBox4: TColorBox;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    ColorBox5: TColorBox;
    SEtransp2: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    Label17: TLabel;
    CBMarkIgnor: TCheckBox;
    CBPathIgnor: TCheckBox;
    CBPolyIgnor: TCheckBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    FileName:string;
  end;

var
  FImport: TFImport;

implementation

uses
  u_GlobalState,
  u_KmlInfoSimple,
  t_GeoTypes;
  
{$R *.dfm}

procedure TFImport.SpeedButton1Click(Sender: TObject);
begin
 if ColorDialog1.Execute then ColorBox1.Selected:=ColorDialog1.Color;
end;

procedure TFImport.SpeedButton2Click(Sender: TObject);
begin
 if ColorDialog1.Execute then ColorBox2.Selected:=ColorDialog1.Color;
end;

procedure TFImport.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TCustomBitmap32;
  Bitmap2: TBitmap32;
begin
  ComboBox1.Canvas.FillRect(Rect);

  Bitmap:=TCustomBitmap32.Create;
  try
    Bitmap.Assign(TCustomBitmap32(ComboBox1.Items.Objects[Index]));
    Bitmap.DrawMode:=dmBlend;
    Bitmap.Resampler:=TKernelResampler.Create;
    TKernelResampler(Bitmap.Resampler).Kernel:=TCubicKernel.Create;

    Bitmap2:=TBitmap32.Create;
    try
      Bitmap2.SetSize(31,31);
      Bitmap2.Clear(clWhite32);
      Bitmap2.Draw(Bounds(0, 0, 31,31), Bounds(0, 0, Bitmap.Width,Bitmap.Height),Bitmap);
      Bitmap2.DrawTo(
        ComboBox1.Canvas.Handle,
        Bounds(Rect.Left + 2, Rect.Top + 2, 31,31),
        Bounds(0, 0, Bitmap2.Width,Bitmap2.Height)
      );
    finally
      Bitmap2.Free;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TFImport.FormActivate(Sender: TObject);
begin
 ComboBox1.Items.Assign(GState.MarkIcons);
 ComboBox1.Repaint;
 ComboBox1.ItemIndex:=0;
end;

procedure TFImport.SpeedButton3Click(Sender: TObject);
begin
 if ColorDialog1.Execute then ColorBox1.Selected:=ColorDialog1.Color;
end;

procedure TFImport.FormShow(Sender: TObject);
begin
 Kategory2StringsWithObjects(CBKateg.Items);
end;

procedure TFImport.Button2Click(Sender: TObject);
begin
 close;
end;

procedure TFImport.Button1Click(Sender: TObject);
var KML:TKmlInfoSimple;
    PLT:TPLT;
    i,j,lenarr:integer;
    ms:TMemoryStream;
    alltl,allbr:TExtendedPoint;
    markignor,pathignor,polyignor:boolean;
    VCategory: TCategoryId;
    VId: Integer;
begin
 markignor:=CBMarkIgnor.Checked;
 pathignor:=CBPathIgnor.Checked;
 polyignor:=CBPolyIgnor.Checked;
  begin
   if CBKateg.ItemIndex < 0 then begin
    VId := AddKategory(CBKateg.Text);
   end else begin
    VCategory := TCategoryId(CBKateg.Items.Objects[CBKateg.ItemIndex]);
    if VCategory <> nil then begin
      VId := VCategory.id;
    end else begin
      VId:=AddKategory(CBKateg.Text);
    end;
   end;
   if (LowerCase(ExtractFileExt(FileName))='.kml') or (LowerCase(ExtractFileExt(FileName))='.kmz') then
    begin
     KML:=TKmlInfoSimple.Create;
     if (LowerCase(ExtractFileExt(FileName))='.kml') then begin
       GState.KmlLoader.LoadFromFile(FileName, KML);
     end else if (LowerCase(ExtractFileExt(FileName))='.kmz') then begin
       GState.KmzLoader.LoadFromFile(FileName, KML);
     end else begin
       Abort;
     end;
     for i:=0 to length(KML.Data)-1 do
      begin
       lenarr:=length(KML.Data[i].coordinates);
       if (length(KML.Data[i].coordinates)=1) then
        begin
         if markignor then Continue;
         Fmain.CDSmarks.Insert;
         BlobFromExtArr(KML.Data[i].coordinates[0], Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=KML.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=KML.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit1.Value;
         Fmain.CDSmarks.FieldByName('Scale2').AsInteger:=SpinEdit2.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox1.Selected),round(((100-SEtransp.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('Color2').AsFloat:=SetAlpha(Color32(ColorBox2.Selected),round(((100-SEtransp.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('PicName').AsString:=ComboBox1.Text;
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=KML.Data[i].coordinates[0].x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=KML.Data[i].coordinates[0].y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=KML.Data[i].coordinates[0].x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=KML.Data[i].coordinates[0].y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end
       else
       if (KML.Data[i].coordinates[0].X=KML.Data[i].coordinates[lenarr-1].X)and
          (KML.Data[i].coordinates[0].Y=KML.Data[i].coordinates[lenarr-1].Y) then
        begin
         if polyignor then Continue;
         Fmain.CDSmarks.Insert;
         alltl:=KML.Data[i].coordinates[0];
         allbr:=KML.Data[i].coordinates[0];
         for j:=1 to lenarr-1 do
          begin
           if alltl.x>KML.Data[i].coordinates[j].x then alltl.x:=KML.Data[i].coordinates[j].x;
           if alltl.y<KML.Data[i].coordinates[j].y then alltl.y:=KML.Data[i].coordinates[j].y;
           if allbr.x<KML.Data[i].coordinates[j].x then allbr.x:=KML.Data[i].coordinates[j].x;
           if allbr.y>KML.Data[i].coordinates[j].y then allbr.y:=KML.Data[i].coordinates[j].y;
          end;
         BlobFromExtArr(KML.Data[i].coordinates, Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=KML.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=KML.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit5.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox4.Selected),round(((100-SpinEdit6.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('Color2').AsFloat:=SetAlpha(Color32(ColorBox5.Selected),round(((100-SEtransp2.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=alltl.x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=alltl.y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=allbr.x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=allbr.y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end
       else
       if (KML.Data[i].coordinates[0].X<>KML.Data[i].coordinates[lenarr-1].X)or
          (KML.Data[i].coordinates[0].Y<>KML.Data[i].coordinates[lenarr-1].Y) then
        begin
         if pathignor then Continue;
         Fmain.CDSmarks.Insert;
         alltl:=KML.Data[i].coordinates[0];
         allbr:=KML.Data[i].coordinates[0];
         for j:=1 to lenarr-1 do
          begin
           if alltl.x>KML.Data[i].coordinates[j].x then alltl.x:=KML.Data[i].coordinates[j].x;
           if alltl.y<KML.Data[i].coordinates[j].y then alltl.y:=KML.Data[i].coordinates[j].y;
           if allbr.x<KML.Data[i].coordinates[j].x then allbr.x:=KML.Data[i].coordinates[j].x;
           if allbr.y>KML.Data[i].coordinates[j].y then allbr.y:=KML.Data[i].coordinates[j].y;
          end;
         BlobFromExtArr(KML.Data[i].coordinates, Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=KML.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=KML.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit3.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox3.Selected),round(((100-SpinEdit4.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=alltl.x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=alltl.y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=allbr.x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=allbr.y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end;
      end;
     KML.Free;
    end;
   if LowerCase(ExtractFileExt(FileName))='.plt' then
    begin
     PLT:=TPLT.Create;
     PLT.loadFromFile(FileName);
     for i:=0 to length(PLT.Data)-1 do
      begin
       lenarr:=length(PLT.Data[i].coordinates);
       if (length(PLT.Data[i].coordinates)=1) then
        begin
         if markignor then Continue;
         Fmain.CDSmarks.Insert;
         BlobFromExtArr(PLT.Data[i].coordinates[0], Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=PLT.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=PLT.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit1.Value;
         Fmain.CDSmarks.FieldByName('Scale2').AsInteger:=SpinEdit2.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox1.Selected),round(((100-SEtransp.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('Color2').AsFloat:=SetAlpha(Color32(ColorBox2.Selected),round(((100-SEtransp.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('PicName').AsString:=ComboBox1.Text;
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=PLT.Data[i].coordinates[0].x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=PLT.Data[i].coordinates[0].y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=PLT.Data[i].coordinates[0].x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=PLT.Data[i].coordinates[0].y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end
       else
       if (PLT.Data[i].coordinates[0].X=PLT.Data[i].coordinates[lenarr-1].X)and
          (PLT.Data[i].coordinates[0].Y=PLT.Data[i].coordinates[lenarr-1].Y) then
        begin
         if polyignor then Continue;
         Fmain.CDSmarks.Insert;
         alltl:=PLT.Data[i].coordinates[0];
         allbr:=PLT.Data[i].coordinates[0];
         for j:=1 to lenarr-1 do
          begin
           if alltl.x>PLT.Data[i].coordinates[j].x then alltl.x:=PLT.Data[i].coordinates[j].x;
           if alltl.y<PLT.Data[i].coordinates[j].y then alltl.y:=PLT.Data[i].coordinates[j].y;
           if allbr.x<PLT.Data[i].coordinates[j].x then allbr.x:=PLT.Data[i].coordinates[j].x;
           if allbr.y>PLT.Data[i].coordinates[j].y then allbr.y:=PLT.Data[i].coordinates[j].y;
          end;
         BlobFromExtArr(PLT.Data[i].coordinates, Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=PLT.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=PLT.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit5.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox4.Selected),round(((100-SpinEdit6.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('Color2').AsFloat:=SetAlpha(Color32(ColorBox5.Selected),round(((100-SEtransp2.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=alltl.x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=alltl.y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=allbr.x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=allbr.y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end
       else
       if (PLT.Data[i].coordinates[0].X<>PLT.Data[i].coordinates[lenarr-1].X)or
          (PLT.Data[i].coordinates[0].Y<>PLT.Data[i].coordinates[lenarr-1].Y) then
        begin
         if pathignor then Continue;
         Fmain.CDSmarks.Insert;
         alltl:=PLT.Data[i].coordinates[0];
         allbr:=PLT.Data[i].coordinates[0];
         for j:=1 to lenarr-1 do
          begin
           if alltl.x>PLT.Data[i].coordinates[j].x then alltl.x:=PLT.Data[i].coordinates[j].x;
           if alltl.y<PLT.Data[i].coordinates[j].y then alltl.y:=PLT.Data[i].coordinates[j].y;
           if allbr.x<PLT.Data[i].coordinates[j].x then allbr.x:=PLT.Data[i].coordinates[j].x;
           if allbr.y>PLT.Data[i].coordinates[j].y then allbr.y:=PLT.Data[i].coordinates[j].y;
          end;
         BlobFromExtArr(PLT.Data[i].coordinates, Fmain.CDSmarks.FieldByName('LonLatArr'));
         Fmain.CDSmarks.FieldByName('name').AsString:=PLT.Data[i].Name;
         Fmain.CDSmarks.FieldByName('descr').AsString:=PLT.Data[i].description;
         Fmain.CDSmarks.FieldByName('Visible').AsBoolean:=true;
         Fmain.CDSmarks.FieldByName('Scale1').AsInteger:=SpinEdit3.Value;
         Fmain.CDSmarks.FieldByName('Color1').AsFloat:=SetAlpha(Color32(ColorBox3.Selected),round(((100-SpinEdit4.Value)/100)*256));
         Fmain.CDSmarks.FieldByName('LonL').AsFloat:=alltl.x;
         Fmain.CDSmarks.FieldByName('LatT').AsFloat:=alltl.y;
         Fmain.CDSmarks.FieldByName('LonR').AsFloat:=allbr.x;
         Fmain.CDSmarks.FieldByName('LatB').AsFloat:=allbr.y;
         Fmain.CDSmarks.FieldByName('categoryid').AsInteger:=VId;
        end;
      end;
     plt.Free;
    end;
   SaveMarks2File;
//   Fmain.CDSmarks.ApplyRange;
//   Fmain.CDSmarks.MergeChangeLog;
//   Fmain.CDSmarks.SaveToFile(GState.MarksFileName,dfXMLUTF8);
  end;
 close;
end;

end.
