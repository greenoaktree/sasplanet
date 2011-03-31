unit u_SensorViewListGeneratorStuped;

interface

uses
  Classes,
  TB2Item,
  TB2Dock,
  i_JclNotify,
  i_GUIDList,
  i_SensorViewListGenerator;

type
  TSensorViewListGeneratorStuped = class(TInterfacedObject, ISensorViewListGenerator)
  private
    FTimerNoifier: IJclNotifier;
    FOwner: TComponent;
    FDefaultDoc: TTBDock;
    FParentMenu: TTBCustomItem;
  protected
    function CreateSensorViewList(ASensorList: IInterfaceList): IGUIDInterfaceList;
  public
    constructor Create(
      ATimerNoifier: IJclNotifier;
      AOwner: TComponent;
      ADefaultDoc: TTBDock;
      AParentMenu: TTBCustomItem
    );
  end;

implementation

uses
  ActiveX,
  SysUtils,
  u_GUIDInterfaceList,
  i_Sensor,
  u_SensorViewTextTBXPanel,
  u_SensorViewConfigSimple;

{ TSensorViewListGeneratorStuped }

constructor TSensorViewListGeneratorStuped.Create(
  ATimerNoifier: IJclNotifier;
  AOwner: TComponent;
  ADefaultDoc: TTBDock; AParentMenu: TTBCustomItem);
begin
  FTimerNoifier := ATimerNoifier;
  FOwner := AOwner;
  FDefaultDoc := ADefaultDoc;
  FParentMenu := AParentMenu;
end;

function TSensorViewListGeneratorStuped.CreateSensorViewList(
  ASensorList: IInterfaceList): IGUIDInterfaceList;
var
  VGUID: TGUID;
  i: Integer;
  VSensor: ISensor;
  VSensorText: ISensorText;
  VSensorViewConfig: ISensorViewConfig;
  VSensorView: ISensorView;
begin
  FDefaultDoc.BeginUpdate;
  try
    Result := TGUIDInterfaceList.Create;
    for i := 0 to ASensorList.Count - 1 do begin
      VSensor := ISensor(ASensorList.Items[i]);
      VGUID := VSensor.GetGUID;
      if IsEqualGUID(VSensor.GetSensorTypeIID, ISensorText) then begin
        VSensorText := VSensor as ISensorText;
        VSensorViewConfig := TSensorViewConfigSimple.Create;
        VSensorView := TSensorViewTextTBXPanel.Create(VSensorText, VSensorViewConfig, FTimerNoifier, FOwner, FDefaultDoc, FParentMenu);
        Result.Add(VGUID, VSensorView);
      end;
    end;
  finally
    FDefaultDoc.EndUpdate;
    FDefaultDoc.CommitNewPositions := True;
    FDefaultDoc.ArrangeToolbars;
  end;
end;

end.
