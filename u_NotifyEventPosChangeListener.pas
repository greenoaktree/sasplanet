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

unit u_NotifyEventPosChangeListener;

interface

uses
  i_JclNotify,
  u_JclNotify,
  i_LocalCoordConverter,
  i_PosChangeMessage;

type
  TPosChangeNotifyEvent = procedure(ANewConverter: ILocalCoordConverter) of object;

  TPosChangeNotifyEventListener = class(TJclBaseListener)
  private
    FEvent: TPosChangeNotifyEvent;
  protected
    procedure DoEvent(AMessage: IPosChangeMessage); virtual;
    procedure Notification(msg: IJclNotificationMessage); override;
  public
    constructor Create(AEvent: TPosChangeNotifyEvent);
  end;

implementation

{ TPosChangeNotifyEventListener }

constructor TPosChangeNotifyEventListener.Create(AEvent: TPosChangeNotifyEvent);
begin
  FEvent := AEvent;
end;

procedure TPosChangeNotifyEventListener.DoEvent(AMessage: IPosChangeMessage);
begin
  if Assigned(FEvent) then begin
    FEvent(AMessage.GetVisualCoordConverter);
  end;
end;

procedure TPosChangeNotifyEventListener.Notification(
  msg: IJclNotificationMessage);
begin
  inherited;
  DoEvent(IPosChangeMessage(msg));
end;

end.
