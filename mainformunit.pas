unit MainFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, XMLPropStorage, PlayingFieldUnit, Buttons,
  settingunit, GameResultFormUnit;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    FGameResult:TGameResult;
    PlayingPanel:TPlayingField;
    NewGameButton: TButton;
    ImLst: TImageList;
    Panel1: TPanel;
    SBPanel: TStatusBar;
    SpeedButton1: TSpeedButton;
    XMLPrStr: TXMLPropStorage;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure NewGameButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SBTimerTimer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure CreateNewGame;
  private
    procedure SetGameTime(AValue: Integer);
    procedure GemeOver(Sender: TObject);
    procedure SetColFlag(Sender: TObject);
  private
    WGame :Integer;
    HGame :Integer;
    ColBomb :Integer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.NewGameButtonClick(Sender: TObject);
begin
  SetGameTime(0);
  PlayingPanel.CreateNewGame();
  SetColFlag(PlayingPanel);
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  with XMLPrStr do
    begin
      WriteInteger('width', WGame);
      WriteInteger('height', HGame);
      WriteInteger('colbomb', ColBomb);
      WriteString('GameResult', FGameResult.GameRusult);
    end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  FGameResult.ShowResultForm;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FGameResult := TGameResult.Create(Self);
  with XMLPrStr do
    begin
      WGame := ReadInteger('width', 10);
      HGame := ReadInteger('height', 10);
      ColBomb := ReadInteger('colbomb', 10);
      FGameResult.GameRusult := ReadString('GameResult', '');
    end;
  CreateNewGame;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  PlayingPanel.Destroy;
  FGameResult.Destroy;
end;

procedure TMainForm.SBTimerTimer(Sender: TObject);
begin
  SetGameTime(TPlayingField(Sender).GameTime);
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
  var SettingForm: TSpSettingForm;
begin
  SettingForm := TSpSettingForm.Create(Self, WGame, HGame, ColBomb);
  if SettingForm.ShowModal = mrOK then
     begin
       PlayingPanel.Destroy;
       WGame := SettingForm.WidthGame;
       HGame := SettingForm.HeigthGame;
       ColBomb := SettingForm.ColBomGame;
       CreateNewGame;
     end;
  SettingForm.Destroy;
end;

procedure TMainForm.CreateNewGame;
 var Ppr:Integer;
begin
  Ppr := 3;
  {$IFDEF UNIX}
  Ppr := 0;
  {$ENDIF}
  SetGameTime(0);
  MainForm.BorderStyle:= bsSizeable;
  MainForm.Height:=5+42+17+(HGame)*22+Ppr;
  MainForm.Width:=2+2+(WGame)*23;
  PlayingPanel := TPlayingField.Create(MainForm,WGame,HGame,ColBomb);
  with PlayingPanel do
    begin
      ImgList := MainForm.ImLst;
      OnTimeClock:=@SBTimerTimer;
      OnGameOver:=@GemeOver;
      OnColFlag:=@SetColFlag;
      Align := alClient;
      CreateNewGame();
    end;
  MainForm.BorderStyle:= bsDialog;
end;

procedure TMainForm.SetGameTime(AValue: Integer);
begin
  SBPanel.Panels[1].Text:=GetStTime(AValue) + ' ';
end;

procedure TMainForm.GemeOver(Sender: TObject);
begin
  if TPlayingField(Sender).GameViktory then
     FGameResult.VerifyGameResult(WGame,HGame,ColBomb,TPlayingField(Sender).GameTime);
end;

procedure TMainForm.SetColFlag(Sender: TObject);
begin
  SBPanel.Panels[0].Text:=IntToStr(TPlayingField(Sender).ColBomb)+'/'+
    IntToStr(TPlayingField(Sender).ColFlag);
end;

end.

