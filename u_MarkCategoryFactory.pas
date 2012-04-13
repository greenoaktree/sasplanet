{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2011, SAS.Planet development team.                      *}
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

unit u_MarkCategoryFactory;

interface

uses
  i_MarkCategory,
  i_MarkCategoryFactoryConfig,
  i_MarkCategoryFactory,
  i_MarkCategoryFactoryDbInternal;

type
  TMarkCategoryFactory = class(TInterfacedObject, IMarkCategoryFactory, IMarkCategoryFactoryDbInternal)
  private
    FConfig: IMarkCategoryFactoryConfig;
    FDbCode: Integer;
  protected
    function CreateNew(const AName: string): IMarkCategory;
    function Modify(
      const ASource: IMarkCategory;
      const AName: string;
      AVisible: Boolean;
      AAfterScale: integer;
      ABeforeScale: integer
    ): IMarkCategory;
    function ModifyVisible(
      const ASource: IMarkCategory;
      AVisible: Boolean
    ): IMarkCategory;
  protected
    function CreateCategory(
      AId: Integer;
      const AName: string;
      AVisible: Boolean;
      AAfterScale: integer;
      ABeforeScale: integer
    ): IMarkCategory;
  public
    constructor Create(
      const ADbCode: Integer;
      const AConfig: IMarkCategoryFactoryConfig
    );
  end;

implementation

uses
  SysUtils,
  i_MarksDbSmlInternal,
  u_MarkCategory;

{ TMarkCategoryFactory }

constructor TMarkCategoryFactory.Create(
  const ADbCode: Integer;
  const AConfig: IMarkCategoryFactoryConfig
);
begin
  FDbCode := ADbCode;
  FConfig := AConfig;
end;

function TMarkCategoryFactory.CreateCategory(
  AId: Integer;
  const AName: string;
  AVisible: Boolean;
  AAfterScale, ABeforeScale: integer
): IMarkCategory;
begin
  Result := TMarkCategory.Create(
    FDbCode,
    AId,
    AName,
    AVisible,
    AAfterScale,
    ABeforeScale
  );
end;

function TMarkCategoryFactory.CreateNew(const AName: string): IMarkCategory;
var
  VName: string;
  VAfterScale, VBeforeScale: Integer;
begin
  VName := AName;
  FConfig.LockRead;
  try
    if VName = '' then begin
      VName := FConfig.DefaultName.Value;
    end;
    VAfterScale := FConfig.AfterScale;
    VBeforeScale := FConfig.BeforeScale;
  finally
    FConfig.UnlockRead;
  end;

  Result :=
    CreateCategory(
      -1,
      VName,
      True,
      VAfterScale,
      VBeforeScale
    );
end;

function TMarkCategoryFactory.Modify(
  const ASource: IMarkCategory;
  const AName: string;
  AVisible: Boolean;
  AAfterScale, ABeforeScale: integer
): IMarkCategory;
var
  VName: string;
  VId: Integer;
  VCategoryInternal: IMarkCategorySMLInternal;
begin
  VName := AName;
  FConfig.LockRead;
  try
    if VName = '' then begin
      VName := FConfig.DefaultName.Value;
    end;
  finally
    FConfig.UnlockRead;
  end;

  VId := -1;
  if Supports(ASource, IMarkCategorySMLInternal, VCategoryInternal) then begin
    VId := VCategoryInternal.Id;
  end;

  Result :=
    CreateCategory(
      VId,
      VName,
      AVisible,
      AAfterScale,
      ABeforeScale
    );
end;

function TMarkCategoryFactory.ModifyVisible(
  const ASource: IMarkCategory;
  AVisible: Boolean
): IMarkCategory;
var
  VId: Integer;
  VCategoryInternal: IMarkCategorySMLInternal;
begin
  VId := -1;
  if Supports(ASource, IMarkCategorySMLInternal, VCategoryInternal) then begin
    VId := VCategoryInternal.Id;
  end;

  Result :=
    CreateCategory(
      VId,
      ASource.Name,
      AVisible,
      ASource.AfterScale,
      ASource.BeforeScale
    );
end;

end.
