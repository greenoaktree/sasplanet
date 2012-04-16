object frSearchResultsItem: TfrSearchResultsItem
  Left = 0
  Top = 0
  Width = 451
  Height = 64
  Align = alTop
  AutoSize = True
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object Bevel1: TBevel
    AlignWithMargins = True
    Left = 3
    Top = 65
    Width = 445
    Height = 5
    Margins.Bottom = 0
    Align = alTop
    Shape = bsTopLine
    ExplicitTop = 79
    ExplicitWidth = 283
  end
  object PanelCaption: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 22
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 0
    object LabelCaption: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 445
      Height = 16
      Cursor = crHandPoint
      Align = alTop
      Caption = '_'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      OnClick = LabelCaptionClick
      ExplicitWidth = 7
    end
  end
  object PanelFullDesc: TPanel
    Left = 0
    Top = 42
    Width = 451
    Height = 20
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 39
    object LabelFullDesc: TLabel
      AlignWithMargins = True
      Left = 376
      Top = 3
      Width = 72
      Height = 14
      Cursor = crHandPoint
      Align = alRight
      Alignment = taRightJustify
      Caption = 'Full Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnMouseUp = LabelFullDescMouseUp
      ExplicitHeight = 13
    end
  end
  object PanelDesc: TPanel
    Left = 0
    Top = 22
    Width = 451
    Height = 20
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 2
    object LabelDesc: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 445
      Height = 14
      Align = alTop
      Caption = '_'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnDblClick = LabelDescDblClick
      ExplicitWidth = 6
    end
  end
end
