unit u_MarksSystem;

interface

uses
  Windows,
  Classes,
  i_ConfigDataProvider,
  i_ConfigDataWriteProvider,
  i_MarksSimple,
  i_MarkPicture,
  i_HtmlToHintTextConverter,
  i_MarksFactoryConfig,
  i_MarkCategory,
  i_MarkCategoryFactoryConfig,
  i_MarkCategoryDB,
  i_MarkCategoryDBSmlInternal,
  i_MarksDb,
  i_MarksDbSmlInternal,
  i_StaticTreeItem,
  i_StaticTreeBuilder,
  u_MarksDb,
  u_MarkCategoryDB;

type
  TMarksSystem = class
  private
    FBasePath: string;
    FMarksFactoryConfig: IMarksFactoryConfig;
    FMarksDb: IMarksDb;
    FMarksDbInternal: IMarksDbSmlInternal;
    FCategoryDB: IMarkCategoryDB;
    FCategoryDBInternal: IMarkCategoryDBSmlInternal;
    FCategoryTreeBuilder: IStaticTreeBuilder;
    FMarksSubsetTreeBuilder: IStaticTreeBuilder;
  public
    constructor Create(
      ABasePath: string;
      AMarkPictureList: IMarkPictureList;
      AHintConverter: IHtmlToHintTextConverter;
      ACategoryFactoryConfig: IMarkCategoryFactoryConfig
    );
    destructor Destroy; override;

    procedure ReadConfig(AConfigData: IConfigDataProvider);
    procedure WriteConfig(AConfigData: IConfigDataWriteProvider);

    property MarksDb: IMarksDb read FMarksDb;
    property CategoryDB: IMarkCategoryDB read FCategoryDB;
    property MarksFactoryConfig: IMarksFactoryConfig read FMarksFactoryConfig;

    function GetVisibleCategories(AZoom: Byte): IInterfaceList;
    procedure DeleteCategoryWithMarks(ACategory: IMarkCategory);

    function MarksSubsetToStaticTree(ASubset: IMarksSubset): IStaticTreeItem;
    function CategoryListToStaticTree(AList: IInterfaceList): IStaticTreeItem;
  end;


implementation

uses
  SysUtils,
  ActiveX,
  u_StaticTreeBuilderBase,
  u_MarksFactoryConfig;

type
  TStaticTreeByCategoryListBuilder = class(TStaticTreeBuilderBaseBySlash)
  protected
    procedure ProcessItems(ASource: IInterface; AList: TStringList); override;
    function GetNameFromItem(
      ASource: IInterface;
      AItem: IInterface
    ): string; override;
  end;

{ TStaticTreeByCategoryListBuilder }

function TStaticTreeByCategoryListBuilder.GetNameFromItem(
  ASource: IInterface;
  AItem: IInterface
): string;
begin
  Result := (AItem as ICategory).Name;
end;

procedure TStaticTreeByCategoryListBuilder.ProcessItems(
  ASource: IInterface;
  AList: TStringList
);
var
  VList: IInterfaceList;
  i: Integer;
begin
  inherited;
  VList := ASource as IInterfaceList;
  for i := 0 to VList.Count - 1 do begin
    ProcessItem(ASource, VList.Items[i], AList);
  end;
end;

type
  TStaticTreeByMarksSubsetBuilder = class(TStaticTreeBuilderBaseBySlash)
  protected
    procedure ProcessItems(ASource: IInterface; AList: TStringList); override;
    function GetNameFromItem(
      ASource: IInterface;
      AItem: IInterface
    ): string; override;
  end;

{ TStaticTreeByMarksSubsetBuilder }

function TStaticTreeByMarksSubsetBuilder.GetNameFromItem(
  ASource: IInterface;
  AItem: IInterface
): string;
var
  VMark: IMark;
begin
  VMark := AItem as IMark;
  if VMark.Category <> nil then begin
    Result := VMark.Category.Name + LevelsSeparator + VMark.Name;
  end else begin
    Result := LevelsSeparator + VMark.Name;
  end;
end;

procedure TStaticTreeByMarksSubsetBuilder.ProcessItems(ASource: IInterface;
  AList: TStringList);
var
  VSubset: IMarksSubset;
  VEnum: IEnumUnknown;
  VMark: IMark;
  i: Cardinal;
begin
  inherited;
  VSubset := ASource as IMarksSubset;
  VEnum := VSubset.GetEnum;
  while (VEnum.Next(1, VMark, @i) = S_OK) do begin
    ProcessItem(ASource, VMark, AList);
  end;
end;

{ TMarksSystem }

constructor TMarksSystem.Create(
  ABasePath: string;
  AMarkPictureList: IMarkPictureList;
  AHintConverter: IHtmlToHintTextConverter;
  ACategoryFactoryConfig: IMarkCategoryFactoryConfig
);
var
  VCategoryDb: TMarkCategoryDB;
  VMarksDb: TMarksDb;
begin
  FBasePath := ABasePath;
  VCategoryDB := TMarkCategoryDB.Create(ABasePath, ACategoryFactoryConfig);
  FCategoryDB := VCategoryDb;
  FCategoryDBInternal := VCategoryDb;
  FMarksFactoryConfig :=
    TMarksFactoryConfig.Create(
      FCategoryDBInternal,
      AMarkPictureList
    );
  VMarksDb :=
    TMarksDb.Create(
      ABasePath,
      FCategoryDBInternal,
      AHintConverter,
      FMarksFactoryConfig
    );
  FMarksDb := VMarksDb;
  FMarksDbInternal := VMarksDb;
  FCategoryTreeBuilder := TStaticTreeByCategoryListBuilder.Create('\', '');
  FMarksSubsetTreeBuilder := TStaticTreeByMarksSubsetBuilder.Create('\', '');
end;

destructor TMarksSystem.Destroy;
begin
  FMarksDb := nil;
  FMarksDbInternal := nil;
  FCategoryDB := nil;
  FCategoryDBInternal := nil;
  FMarksFactoryConfig := nil;
  inherited;
end;

function TMarksSystem.CategoryListToStaticTree(
  AList: IInterfaceList
): IStaticTreeItem;
begin
  Result := FCategoryTreeBuilder.BuildStatic(AList);
end;

procedure TMarksSystem.DeleteCategoryWithMarks(ACategory: IMarkCategory);
begin
  FMarksDb.DeleteMarksByCategoryID(ACategory);
  FCategoryDB.DeleteCategory(ACategory);
end;

function TMarksSystem.GetVisibleCategories(AZoom: Byte): IInterfaceList;
var
  VList: IInterfaceList;
  VCategory: IMarkCategory;
  i: Integer;
begin
  Result := TInterfaceList.Create;
  VList := FCategoryDB.GetCategoriesList;
  for i := 0 to VList.Count - 1 do begin
    VCategory := IMarkCategory(VList[i]);
    if
      (VCategory.visible) and
      (VCategory.AfterScale <= AZoom + 1) and
      (VCategory.BeforeScale >= AZoom + 1)
    then begin
      Result.Add(VCategory);
    end;
  end;
end;

function TMarksSystem.MarksSubsetToStaticTree(
  ASubset: IMarksSubset
): IStaticTreeItem;
begin
  Result := FMarksSubsetTreeBuilder.BuildStatic(ASubset);
end;

procedure TMarksSystem.ReadConfig(AConfigData: IConfigDataProvider);
begin
  FMarksDbInternal.LoadMarksFromFile;
  FCategoryDBInternal.LoadCategoriesFromFile;
  FMarksFactoryConfig.ReadConfig(AConfigData);
end;

procedure TMarksSystem.WriteConfig(AConfigData: IConfigDataWriteProvider);
begin
  FMarksFactoryConfig.WriteConfig(AConfigData);
  FCategoryDBInternal.SaveCategory2File;
  FMarksDbInternal.SaveMarks2File;
end;

end.



