object FImport: TFImport
  Left = 245
  Top = 207
  BorderStyle = bsDialog
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1084#1087#1086#1088#1090#1072
  ClientHeight = 385
  ClientWidth = 505
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object lblCategory: TLabel
    Left = 8
    Top = 10
    Width = 58
    Height = 13
    Caption = #1050#1072#1090#1077#1075#1086#1088#1080#1103':'
  end
  object CBKateg: TComboBox
    Left = 72
    Top = 8
    Width = 425
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 64
    Width = 489
    Height = 81
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1084#1077#1090#1086#1082
    TabOrder = 1
    object Label3: TLabel
      Left = 128
      Top = 24
      Width = 64
      Height = 13
      Caption = #1062#1074#1077#1090' '#1090#1077#1082#1089#1090#1072
    end
    object Label4: TLabel
      Left = 128
      Top = 48
      Width = 53
      Height = 13
      Caption = #1062#1074#1077#1090' '#1090#1077#1085#1080
    end
    object Label5: TLabel
      Left = 256
      Top = 24
      Width = 78
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1096#1088#1080#1092#1090#1072
    end
    object Label6: TLabel
      Left = 256
      Top = 48
      Width = 74
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1080#1082#1086#1085#1082#1080
    end
    object Label7: TLabel
      Left = 392
      Top = 24
      Width = 85
      Height = 13
      Caption = #1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' %'
    end
    object SpeedButton1: TSpeedButton
      Left = 230
      Top = 21
      Width = 17
      Height = 22
      Caption = '...'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 230
      Top = 45
      Width = 17
      Height = 22
      Caption = '...'
      OnClick = SpeedButton2Click
    end
    object Label17: TLabel
      Left = 16
      Top = 32
      Width = 37
      Height = 13
      Caption = #1048#1082#1086#1085#1082#1072
    end
    object ColorBox1: TColorBox
      Left = 192
      Top = 21
      Width = 38
      Height = 22
      Selected = clYellow
      Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 0
    end
    object SpinEdit1: TSpinEdit
      Left = 344
      Top = 21
      Width = 41
      Height = 22
      MaxValue = 24
      MinValue = 0
      TabOrder = 1
      Value = 11
    end
    object ColorBox2: TColorBox
      Left = 192
      Top = 45
      Width = 38
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 2
    end
    object SpinEdit2: TSpinEdit
      Left = 344
      Top = 45
      Width = 41
      Height = 22
      MaxValue = 64
      MinValue = 1
      TabOrder = 3
      Value = 32
    end
    object SEtransp: TSpinEdit
      Left = 432
      Top = 43
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
      TabOrder = 4
      Value = 35
    end
    object ComboBox1: TComboBox
      Left = 64
      Top = 21
      Width = 57
      Height = 44
      Hint = #1042#1099#1073#1077#1088#1080#1090#1077' '#1075#1088#1072#1092#1080#1095#1077#1089#1082#1086#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
      Style = csOwnerDrawVariable
      ItemHeight = 38
      ParentShowHint = False
      ShowHint = False
      TabOrder = 5
      OnDrawItem = ComboBox1DrawItem
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 176
    Width = 489
    Height = 57
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1091#1090#1077#1081
    TabOrder = 2
    object Label1: TLabel
      Left = 88
      Top = 24
      Width = 26
      Height = 13
      Caption = #1062#1074#1077#1090
    end
    object Label2: TLabel
      Left = 194
      Top = 24
      Width = 40
      Height = 13
      Caption = #1064#1080#1088#1080#1085#1072
    end
    object Label9: TLabel
      Left = 298
      Top = 24
      Width = 85
      Height = 13
      Caption = #1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' %'
    end
    object SpeedButton3: TSpeedButton
      Left = 155
      Top = 21
      Width = 17
      Height = 22
      Caption = '...'
      OnClick = SpeedButton3Click
    end
    object ColorBox3: TColorBox
      Left = 117
      Top = 21
      Width = 38
      Height = 22
      Selected = clRed
      Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 0
    end
    object SpinEdit3: TSpinEdit
      Left = 237
      Top = 21
      Width = 41
      Height = 22
      MaxValue = 24
      MinValue = 1
      TabOrder = 1
      Value = 2
    end
    object SpinEdit4: TSpinEdit
      Left = 384
      Top = 21
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
      TabOrder = 2
      Value = 35
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 264
    Width = 489
    Height = 81
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1083#1080#1075#1086#1085#1086#1074
    TabOrder = 3
    object Label10: TLabel
      Left = 88
      Top = 24
      Width = 26
      Height = 13
      Caption = #1062#1074#1077#1090
    end
    object Label11: TLabel
      Left = 194
      Top = 24
      Width = 40
      Height = 13
      Caption = #1064#1080#1088#1080#1085#1072
    end
    object Label12: TLabel
      Left = 298
      Top = 24
      Width = 85
      Height = 13
      Caption = #1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' %'
    end
    object SpeedButton4: TSpeedButton
      Left = 155
      Top = 21
      Width = 17
      Height = 22
      Caption = '...'
      OnClick = SpeedButton4Click
    end
    object Label13: TLabel
      Left = 88
      Top = 48
      Width = 26
      Height = 13
      Caption = #1062#1074#1077#1090
    end
    object Label14: TLabel
      Left = 194
      Top = 48
      Width = 85
      Height = 13
      Caption = #1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' %'
    end
    object SpeedButton5: TSpeedButton
      Left = 155
      Top = 45
      Width = 17
      Height = 22
      Caption = '...'
      OnClick = SpeedButton5Click
    end
    object Label15: TLabel
      Left = 8
      Top = 22
      Width = 35
      Height = 13
      Caption = #1051#1080#1085#1080#1103':'
    end
    object Label16: TLabel
      Left = 8
      Top = 46
      Width = 64
      Height = 13
      Caption = #1047#1072#1087#1086#1083#1085#1077#1085#1080#1077':'
    end
    object ColorBox4: TColorBox
      Left = 117
      Top = 21
      Width = 38
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 0
    end
    object SpinEdit5: TSpinEdit
      Left = 237
      Top = 21
      Width = 41
      Height = 22
      MaxValue = 24
      MinValue = 1
      TabOrder = 1
      Value = 2
    end
    object SpinEdit6: TSpinEdit
      Left = 384
      Top = 21
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
      TabOrder = 2
      Value = 35
    end
    object ColorBox5: TColorBox
      Left = 117
      Top = 45
      Width = 38
      Height = 22
      Selected = clWhite
      Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 3
    end
    object SEtransp2: TSpinEdit
      Left = 280
      Top = 45
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
      TabOrder = 4
      Value = 80
    end
  end
  object Button1: TButton
    Left = 424
    Top = 352
    Width = 75
    Height = 25
    Caption = #1053#1072#1095#1072#1090#1100
    TabOrder = 4
    OnClick = Button1Click
  end
  object btnCancel: TButton
    Left = 344
    Top = 352
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    ModalResult = 2
    TabOrder = 5
  end
  object CBMarkIgnor: TCheckBox
    Left = 8
    Top = 40
    Width = 129
    Height = 17
    Caption = #1048#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100' '#1084#1077#1090#1082#1080
    TabOrder = 6
  end
  object CBPathIgnor: TCheckBox
    Left = 8
    Top = 152
    Width = 129
    Height = 17
    Caption = #1048#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100' '#1087#1091#1090#1080
    TabOrder = 7
  end
  object CBPolyIgnor: TCheckBox
    Left = 8
    Top = 240
    Width = 153
    Height = 17
    Caption = #1048#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100' '#1087#1086#1083#1080#1075#1086#1085#1099
    TabOrder = 8
  end
  object ColorDialog1: TColorDialog
    Left = 472
    Top = 32
  end
end
