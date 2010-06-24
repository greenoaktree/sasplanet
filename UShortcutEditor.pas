unit UShortcutEditor;

interface

uses
  Windows,
  Forms,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  ComCtrls,
  Dialogs,
  StdCtrls,
  Menus,
  Buttons,
  IniFiles,
  TB2Item,
  TBX;

type
  TTempShortCut = class(TObject)
    ShortCut:TShortCut;
    MenuItem:TTBCustomItem;
  end;
  TShortcutEditor = class(TObject)
  private
    fMainMenu: TTBCustomItem;
    fSection: String;
    FList: TListBox;
    procedure ListDblClick(Sender: TObject);
    procedure ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ClearList;
    procedure Execute;
  public
    constructor Create(AList:TListBox);
    destructor Destroy; override;
    procedure LoadShortCuts(MainMenu: TTBCustomItem; Section:String);
    procedure Save;
  end;

  TFShortcutChange = class(TForm)
    GroupBox1: TGroupBox;
    HotKey: THotKey;
    Button1: TButton;
    Button2: TButton;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  public
  end;

var
  FShortcutChange: TFShortcutChange;

implementation

uses
  u_GlobalState;

const
  NoHotKey : array [1..12] of string = (
    'NSMB','NLayerSel','TBFillingTypeMap','NLayerParams','TBLang','N002','N003','N004',
    'N005','N006','N007','NFillMap'
  );


{$R *.dfm}

procedure TFShortcutChange.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TFShortcutChange.Button3Click(Sender: TObject);
begin
  HotKey.HotKey := 0;
end;

procedure TFShortcutChange.FormShow(Sender: TObject);
begin
  HotKey.SetFocus;
end;

constructor TShortcutEditor.Create(AList:TListBox);
begin
  FList:=AList;
  FList.OnDrawItem:=ListDrawItem;
  FList.OnDblClick:=ListDblClick;
end;

function inNotHotKey(name:string):boolean;
var i:integer;
begin
 result:=false;
 for i:=1 to length(NoHotKey) do begin
   if name=NoHotKey[i] then begin
    result:=true;
    exit;
   end;
 end;
end;

procedure TShortcutEditor.Execute;

  function GetCaption(aMenu:TTBCustomItem):String;
  var Menu:TTBCustomItem;
      AddName:String;
  begin
   Result:='';
   Menu:=aMenu;
   repeat
    AddName := Menu.Caption;
    if Pos('&', AddName) <> 0 then begin
      Delete(AddName, Pos('&', AddName), 1);
    end;
    if Result = '' then begin
      Result := AddName
    end else begin
      if AddName <> '' then begin
        Result :=AddName+' -> '+Result;
      end;
    end;

    if Assigned(Menu.Parent) then begin
      Menu := Menu.Parent
    end else begin
      Break;
    end;
   until Menu.HasParent = False;
  end;

  procedure AddItems(Menu:TTBCustomItem);
    var i:Integer;
    TempShortCut:  TTempShortCut;
  begin
    for i:=0 to Menu.Count-1 do begin
      if (not(inNotHotKey(Menu.Items[i].Name)))and(Menu.Items[i].ClassType<>TTBXSeparatorItem) then begin
        if (Menu.Items[i].Count=0)and(Menu.Items[i].ClassType=TTBXItem) then begin
          TempShortCut := TTempShortCut.Create;
          TempShortCut.MenuItem:=Menu.Items[i];
          TempShortCut.ShortCut:=Menu.Items[i].ShortCut;
          FList.Items.AddObject(GetCaption(Menu.Items[i]), TempShortCut);
        end;
        if Menu.Items[i].Count>0 then begin
           AddItems(Menu.Items[i]);
        end;
      end;
    end;
  end;

begin
  ClearList;
  AddItems(fMainMenu);
end;

procedure TShortcutEditor.ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var ShortCut:String;
    Icon:TIcon;

  procedure DrawBitmap;
  var btm:TBitmap;
  begin
    btm:=TBitmap.Create;
    if {TTBXToolbar(fMainMenu.ParentComponent).}
    TTempShortCut(FList.Items.Objects[Index]).MenuItem.Images.GetBitmap(TTempShortCut(FList.Items.Objects[Index]).MenuItem.ImageIndex,btm) then begin
      FList.Canvas.Draw(2,Rect.Top+2, btm);
    end;
    freeandnil(btm);
  end;

begin
  with FList.Canvas do begin
    FillRect(Rect);
    ShortCut := ShortCutToText(TTempShortCut(FList.Items.Objects[Index]).ShortCut);

    if TTempShortCut(FList.Items.Objects[Index]).MenuItem.ImageIndex<>-1 then begin
      if Assigned(fMainMenu.Images) then begin
        Icon := TIcon.Create;
        fMainMenu.Images.GetIcon(TTempShortCut(FList.Items.Objects[Index]).MenuItem.ImageIndex, Icon);
        Draw(2,Rect.Top+2, Icon);
        Icon.Free;
      end else begin
        DrawBitmap;
      end
    end else begin
    //  DrawBitmap;
    end;

    TextOut(22,Rect.Top+3, FList.Items[Index]);
    TextOut(Rect.Right-TextWidth(ShortCut)-9,Rect.Top+3, ShortCut);

    Pen.Color := clSilver;
    MoveTo(0, Rect.Bottom-1);
    LineTo(Rect.Right, Rect.Bottom-1);
  end;
end;

procedure TShortcutEditor.ListDblClick(Sender: TObject);

  function ShortCutExists(A:TShortcut):Boolean;
  var i:Integer;
  begin
    Result := False;
    for i := 0 to FList.Items.Count-1 do begin
      if TTempShortCut(FList.Items.Objects[i]).ShortCut = A then begin
        Result := True;
        Break;
      end;
    end;
  end;

begin
  if FList.ItemIndex<>-1 then begin
    FShortcutChange.HotKey.HotKey := TTempShortCut(FList.Items.Objects[FList.ItemIndex]).ShortCut;
    if FShortcutChange.ShowModal = mrOK then begin
      if (ShortCutExists(FShortcutChange.HotKey.HotKey))and(FShortcutChange.HotKey.HotKey<>0) then begin
        ShowMessage('������� ������� ��� ������������, ����������, �������� ������')
      end else begin
        TTempShortCut(FList.Items.Objects[FList.ItemIndex]).ShortCut := FShortcutChange.HotKey.HotKey;
      end;
      FList.Repaint;
    end;
  end;
end;

procedure TShortcutEditor.LoadShortCuts(MainMenu: TTBCustomItem; Section:String);
  procedure LoadItems(Menu:TTBCustomItem);
  var i:Integer;
  begin
    for i := 0 to Menu.Count-1 do begin
      Menu.Items[i].ShortCut := Gstate.MainIni.ReadInteger(Section, Menu.Items[i].name, Menu.Items[i].ShortCut);
      if Menu.Items[i].Count > 0 then begin
        LoadItems(Menu.Items[i]);
      end;
    end;
  end;

begin
  fSection := Section;
  fMainMenu := MainMenu;
  LoadItems(fMainMenu);
  Execute;
end;

procedure TShortcutEditor.Save;
var i:Integer;
begin
  for i := 0 to FList.Items.Count-1 do begin
    Gstate.MainIni.WriteInteger(fSection, TTempShortCut(FList.Items.Objects[i]).MenuItem.Name, TTempShortCut(FList.Items.Objects[i]).ShortCut);
    TTempShortCut(FList.Items.Objects[i]).MenuItem.ShortCut := TTempShortCut(FList.Items.Objects[i]).ShortCut;
  end;
end;

procedure TShortcutEditor.ClearList;
var i:Integer;
begin
  for i := 0 to FList.Items.Count-1 do begin
    FList.Items.Objects[i].Free;
  end;
  FList.Clear;
end;

destructor TShortcutEditor.Destroy;
begin
  ClearList;
  inherited;
end;

end.
