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

unit u_MarkDbByImpl;

interface

uses
  t_GeoTypes,
  i_Listener,
  i_Notifier,
  i_Category,
  i_InterfaceListStatic,
  i_VectorItemSubset,
  i_MarkId,
  i_VectorDataItemSimple,
  i_MarkFactory,
  i_MarkDb,
  i_MarkSystemImplChangeable,
  u_BaseInterfacedObject;

type
  TMarkDbByImpl = class(TBaseInterfacedObject, IMarkDb)
  private
    FMarkSystemImpl: IMarkSystemImplChangeable;
    FNotifier: INotifier;

    FMarkFactory: IMarkFactory;
    FChangeNotifier: INotifier;
    FChangeNotifierInternal: INotifierInternal;
    FImplChangeListener: IListener;
    FDbImplChangeListener: IListener;
  private
    procedure OnImplChange;
    procedure OnDBImplChange;
  private
    function GetMarkByName(
      const AName: string;
      const ACategory: ICategory
    ): IVectorDataItemSimple;

    function GetMarkSubsetByCategoryList(
      const ACategoryList: IInterfaceListStatic;
      const AIncludeHiddenMarks: Boolean
    ): IVectorItemSubset;
    function GetMarkSubsetByCategory(
      const ACategory: ICategory;
      const AIncludeHiddenMarks: Boolean
    ): IVectorItemSubset;
    function GetMarkSubsetByCategoryListInRect(
      const ARect: TDoubleRect;
      const ACategoryList: IInterfaceListStatic;
      const AIncludeHiddenMarks: Boolean
    ): IVectorItemSubset;
    function GetMarkSubsetByCategoryInRect(
      const ARect: TDoubleRect;
      const ACategory: ICategory;
      const AIncludeHiddenMarks: Boolean
    ): IVectorItemSubset;
    function GetMarkSubsetByName(
      const AName: string;
      const AMaxCount: Integer;
      const AIncludeHiddenMarks: Boolean
    ): IVectorItemSubset;

    function UpdateMark(
      const AOldMark: IVectorDataItemSimple;
      const ANewMark: IVectorDataItemSimple
    ): IVectorDataItemSimple;
    function UpdateMarkList(
      const AOldMarkList: IInterfaceListStatic;
      const ANewMarkList: IInterfaceListStatic
    ): IInterfaceListStatic;

    function GetAllMarkIdList: IInterfaceListStatic;
    function GetMarkIdListByCategory(const ACategory: ICategory): IInterfaceListStatic;

    function GetMarkByID(const AMarkId: IMarkId): IVectorDataItemSimple;

    procedure SetMarkVisibleByID(const AMark: IMarkId; AVisible: Boolean);
    procedure SetMarkVisible(const AMark: IVectorDataItemSimple; AVisible: Boolean);

    procedure SetMarkVisibleByIDList(const AMarkList: IInterfaceListStatic; AVisible: Boolean);
    procedure ToggleMarkVisibleByIDList(const AMarkList: IInterfaceListStatic);

    function GetMarkVisibleByID(const AMark: IMarkId): Boolean;
    function GetMarkVisible(const AMark: IVectorDataItemSimple): Boolean;
    procedure SetAllMarksInCategoryVisible(
      const ACategory: ICategory;
      ANewVisible: Boolean
    );

    function GetFactory: IMarkFactory;
    function GetChangeNotifier: INotifier;
  public
    constructor Create(
      const AMarkSystemImpl: IMarkSystemImplChangeable;
      const AMarkFactory: IMarkFactory
    );
    destructor Destroy; override;
  end;

implementation

uses
  i_MarkSystemImpl,
  u_Notifier,
  u_ListenerByEvent;

{ TMarkDbByImpl }

constructor TMarkDbByImpl.Create(
  const AMarkSystemImpl: IMarkSystemImplChangeable;
  const AMarkFactory: IMarkFactory
);
begin
  inherited Create;
  FMarkSystemImpl := AMarkSystemImpl;
  FMarkFactory := AMarkFactory;
  FChangeNotifierInternal := TNotifierBase.Create;
  FChangeNotifier := FChangeNotifierInternal;
  FImplChangeListener := TNotifyNoMmgEventListener.Create(Self.OnImplChange);
  FDbImplChangeListener := TNotifyNoMmgEventListener.Create(Self.OnDbImplChange);

  FMarkSystemImpl.ChangeNotifier.Add(FImplChangeListener);
  OnDBImplChange;
end;

destructor TMarkDbByImpl.Destroy;
begin
  if Assigned(FNotifier) and Assigned(FDbImplChangeListener) then begin
    FNotifier.Remove(FDbImplChangeListener);
    FNotifier := nil;
  end;
  if Assigned(FMarkSystemImpl) and Assigned(FImplChangeListener) then begin
    FMarkSystemImpl.ChangeNotifier.Remove(FImplChangeListener);
    FMarkSystemImpl := nil;
  end;
  inherited;
end;

function TMarkDbByImpl.GetAllMarkIdList: IInterfaceListStatic;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetAllMarkIdList;
  end;
end;

function TMarkDbByImpl.GetChangeNotifier: INotifier;
begin
  Result := FChangeNotifier;
end;

function TMarkDbByImpl.GetFactory: IMarkFactory;
begin
  Result := FMarkFactory;
end;

function TMarkDbByImpl.GetMarkByID(const AMarkId: IMarkId): IVectorDataItemSimple;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkByID(AMarkId);
  end;
end;

function TMarkDbByImpl.GetMarkByName(const AName: string;
  const ACategory: ICategory): IVectorDataItemSimple;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkByName(AName, ACategory);
  end;
end;

function TMarkDbByImpl.GetMarkIdListByCategory(
  const ACategory: ICategory): IInterfaceListStatic;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkIdListByCategory(ACategory);
  end;
end;

function TMarkDbByImpl.GetMarkSubsetByCategory(
  const ACategory: ICategory;
  const AIncludeHiddenMarks: Boolean
): IVectorItemSubset;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkSubsetByCategory(ACategory, AIncludeHiddenMarks);
  end;
end;

function TMarkDbByImpl.GetMarkSubsetByCategoryInRect(
  const ARect: TDoubleRect;
  const ACategory: ICategory;
  const AIncludeHiddenMarks: Boolean
): IVectorItemSubset;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkSubsetByCategoryInRect(ARect, ACategory, AIncludeHiddenMarks);
  end;
end;

function TMarkDbByImpl.GetMarkSubsetByCategoryList(
  const ACategoryList: IInterfaceListStatic;
  const AIncludeHiddenMarks: Boolean): IVectorItemSubset;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkSubsetByCategoryList(ACategoryList, AIncludeHiddenMarks);
  end;
end;

function TMarkDbByImpl.GetMarkSubsetByCategoryListInRect(
  const ARect: TDoubleRect;
  const ACategoryList: IInterfaceListStatic;
  const AIncludeHiddenMarks: Boolean
): IVectorItemSubset;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkSubsetByCategoryListInRect(ARect, ACategoryList, AIncludeHiddenMarks);
  end;
end;

function TMarkDbByImpl.GetMarkSubsetByName(
  const AName: string;
  const AMaxCount: Integer;
  const AIncludeHiddenMarks: Boolean
): IVectorItemSubset;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkSubsetByName(AName, AMaxCount, AIncludeHiddenMarks);
  end;
end;

function TMarkDbByImpl.GetMarkVisible(const AMark: IVectorDataItemSimple): Boolean;
var
  VImpl: IMarkSystemImpl;
begin
  Result := True;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkVisible(AMark);
  end;
end;

function TMarkDbByImpl.GetMarkVisibleByID(const AMark: IMarkId): Boolean;
var
  VImpl: IMarkSystemImpl;
begin
  Result := True;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.GetMarkVisibleByID(AMark);
  end;
end;

procedure TMarkDbByImpl.OnImplChange;
var
  VImpl: IMarkSystemImpl;
begin
  if FNotifier <> nil then begin
    FNotifier.Remove(FDbImplChangeListener);
    FNotifier := nil;
  end;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    FNotifier := VImpl.MarkDb.ChangeNotifier;
    FNotifier.Add(FDbImplChangeListener);
  end;
end;

procedure TMarkDbByImpl.OnDbImplChange;
begin
  FChangeNotifierInternal.Notify(nil);
end;

procedure TMarkDbByImpl.SetAllMarksInCategoryVisible(
  const ACategory: ICategory; ANewVisible: Boolean);
var
  VImpl: IMarkSystemImpl;
begin
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    VImpl.MarkDb.SetAllMarksInCategoryVisible(ACategory, ANewVisible);
  end;
end;

procedure TMarkDbByImpl.SetMarkVisible(const AMark: IVectorDataItemSimple; AVisible: Boolean);
var
  VImpl: IMarkSystemImpl;
begin
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    VImpl.MarkDb.SetMarkVisible(AMark, AVisible);
  end;
end;

procedure TMarkDbByImpl.SetMarkVisibleByID(const AMark: IMarkId;
  AVisible: Boolean);
var
  VImpl: IMarkSystemImpl;
begin
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    VImpl.MarkDb.SetMarkVisibleByID(AMark, AVisible);
  end;
end;

procedure TMarkDbByImpl.SetMarkVisibleByIDList(const AMarkList: IInterfaceListStatic;
  AVisible: Boolean);
var
  VImpl: IMarkSystemImpl;
begin
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    VImpl.MarkDb.SetMarkVisibleByIDList(AMarkList, AVisible);
  end;
end;

procedure TMarkDbByImpl.ToggleMarkVisibleByIDList(
  const AMarkList: IInterfaceListStatic
);
var
  VImpl: IMarkSystemImpl;
begin
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    VImpl.MarkDb.ToggleMarkVisibleByIDList(AMarkList);
  end;
end;

function TMarkDbByImpl.UpdateMark(const AOldMark, ANewMark: IVectorDataItemSimple): IVectorDataItemSimple;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.UpdateMark(AOldMark, ANewMark);
  end;
end;

function TMarkDbByImpl.UpdateMarkList(
  const AOldMarkList, ANewMarkList: IInterfaceListStatic
): IInterfaceListStatic;
var
  VImpl: IMarkSystemImpl;
begin
  Result := nil;
  VImpl := FMarkSystemImpl.GetStatic;
  if VImpl <> nil then begin
    Result := VImpl.MarkDb.UpdateMarkList(AOldMarkList, ANewMarkList);
  end;
end;

end.
