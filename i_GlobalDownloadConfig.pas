{******************************************************************************}
{* SAS.������� (SAS.Planet)                                                   *}
{* Copyright (C) 2007-2011, ������ ��������� SAS.������� (SAS.Planet).        *}
{* ��� ��������� �������� ��������� ����������� ������������. �� ������       *}
{* �������������� �/��� �������������� � �������� �������� �����������       *}
{* ������������ �������� GNU, �������������� ������ ���������� ������������   *}
{* �����������, ������ 3. ��� ��������� ���������������� � �������, ��� ���   *}
{* ����� ��������, �� ��� ������ ��������, � ��� ����� ���������������        *}
{* �������� ��������� ��������� ��� ������� � �������� ��� ������˨�����      *}
{* ����������. �������� ����������� ������������ �������� GNU ������ 3, ���   *}
{* ��������� �������������� ����������. �� ������ ���� �������� �����         *}
{* ����������� ������������ �������� GNU ������ � ����������. � ������ �     *}
{* ����������, ���������� http://www.gnu.org/licenses/.                       *}
{*                                                                            *}
{* http://sasgis.ru/sasplanet                                                 *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit i_GlobalDownloadConfig;

interface

uses
  i_ConfigDataElement;

type
  IGlobalDownloadConfig = interface(IConfigDataElement)
    ['{66442801-51C5-43DF-AB59-747E058A3567}']
    // ���������� � ���������� ����� ���� ��������� ������ �������
    function GetIsGoNextTileIfDownloadError: Boolean;
    procedure SetIsGoNextTileIfDownloadError(AValue: Boolean);
    property IsGoNextTileIfDownloadError: Boolean read GetIsGoNextTileIfDownloadError write SetIsGoNextTileIfDownloadError;

    //������ ����������� ������ �������� � ���������� ������ ������������ �����
    function GetIsUseSessionLastSuccess: Boolean;
    procedure SetIsUseSessionLastSuccess(AValue: Boolean);
    property IsUseSessionLastSuccess: Boolean read GetIsUseSessionLastSuccess write SetIsUseSessionLastSuccess;

    //���������� ���������� � ������ ������������� �� �������
    function GetIsSaveTileNotExists: Boolean;
    procedure SetIsSaveTileNotExists(AValue: Boolean);
    property IsSaveTileNotExists: Boolean read GetIsSaveTileNotExists write SetIsSaveTileNotExists;
  end;

implementation

end.
