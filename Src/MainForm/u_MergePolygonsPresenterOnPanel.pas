{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2014, SAS.Planet development team.                      *}
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
{* http://sasgis.org                                                          *}
{* info@sasgis.org                                                            *}
{******************************************************************************}

unit u_MergePolygonsPresenterOnPanel;

interface

uses
  Classes,
  Controls,
  i_NotifierOperation,
  i_MapViewGoto,
  i_VectorItemSubset,
  i_VectorDataFactory,
  i_GeometryLonLatFactory,
  i_MergePolygonsPresenter,
  i_MergePolygonsResult,
  u_MarkDbGUIHelper,
  u_BaseInterfacedObject,
  fr_MergePolygons;

type
  TMergePolygonsPresenterOnPanel = class(TBaseInterfacedObject, IMergePolygonsPresenter)
  private
    FDrawParent: TWinControl;
    FOnAddItems: TNotifyEvent;
    FAppClosingNotifier: INotifierOneOperation;
    FVectorDataFactory: IVectorDataFactory;
    FVectorGeometryLonLatFactory: IGeometryLonLatFactory;
    FMergePolygonsResult: IMergePolygonsResult;
    FMapGoto: IMapViewGoto;
    FMarkDBGUI: TMarkDbGUIHelper;
    FfrMergePolygons: TfrMergePolygons;
  private
    { IMergePolygonsPresenter }
    procedure AddVectorItems(const AItems: IVectorItemSubset);
    procedure ClearAll;
  public
    constructor Create(
      ADrawParent: TWinControl;
      AOnAddItems: TNotifyEvent;
      const AAppClosingNotifier: INotifierOneOperation;
      const AVectorDataFactory: IVectorDataFactory;
      const AVectorGeometryLonLatFactory: IGeometryLonLatFactory;
      const AMergePolygonsResult: IMergePolygonsResult;
      const AMapGoto: IMapViewGoto;
      const AMarkDBGUI: TMarkDbGUIHelper
    );
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  i_GeometryLonLat,
  i_VectorDataItemSimple;

{ TMergePolygonsPresenterOnPanel }

constructor TMergePolygonsPresenterOnPanel.Create(
  ADrawParent: TWinControl;
  AOnAddItems: TNotifyEvent;
  const AAppClosingNotifier: INotifierOneOperation;
  const AVectorDataFactory: IVectorDataFactory;
  const AVectorGeometryLonLatFactory: IGeometryLonLatFactory;
  const AMergePolygonsResult: IMergePolygonsResult;
  const AMapGoto: IMapViewGoto;
  const AMarkDBGUI: TMarkDbGUIHelper
);
begin
  inherited Create;

  FDrawParent := ADrawParent;
  FOnAddItems := AOnAddItems;
  FAppClosingNotifier := AAppClosingNotifier;
  FVectorDataFactory := AVectorDataFactory;
  FVectorGeometryLonLatFactory := AVectorGeometryLonLatFactory;
  FMergePolygonsResult := AMergePolygonsResult;
  FMapGoto := AMapGoto;
  FMarkDBGUI := AMarkDBGUI;
  FfrMergePolygons := nil;
end;

destructor TMergePolygonsPresenterOnPanel.Destroy;
begin
  FMarkDBGUI := nil;
  FreeAndNil(FfrMergePolygons);
  inherited Destroy;
end;

procedure TMergePolygonsPresenterOnPanel.AddVectorItems(
  const AItems: IVectorItemSubset
);
var
  I: Integer;
  VItem: IVectorDataItem;
  VPoly: IGeometryLonLatPolygon;
begin
  Assert(Assigned(AItems));

  if not Assigned(FfrMergePolygons) then begin
    FfrMergePolygons :=
      TfrMergePolygons.Create(
        nil,
        FDrawParent,
        FAppClosingNotifier,
        FVectorDataFactory,
        FVectorGeometryLonLatFactory,
        FMergePolygonsResult,
        FMapGoTo,
        FMarkDBGUI
      );
  end;

  FfrMergePolygons.Visible := True;

  for I := 0 to AItems.Count - 1 do begin
    VItem := AItems.Items[I];
    if Supports(VItem.Geometry, IGeometryLonLatPolygon, VPoly) then begin
      FfrMergePolygons.AddPoly(VPoly, VItem.MainInfo);
    end;
  end;

  if Assigned(FOnAddItems) then begin
    FOnAddItems(Self);
  end;
end;

procedure TMergePolygonsPresenterOnPanel.ClearAll;
begin
  if Assigned(FfrMergePolygons) then begin
    FfrMergePolygons.Clear;
    FfrMergePolygons.Visible := False;
  end;
end;

end.
