unit SettingUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin;

type

  { TSpSettingForm }

  TSpSettingForm = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    RButtonNv: TRadioButton;
    RButtonSp: TRadioButton;
    RButtonExp: TRadioButton;
    RButtonMain: TRadioButton;
    RadioGroup1: TRadioGroup;
    HeigthEdit: TSpinEdit;
    ColBombEdit: TSpinEdit;
    WidthEdit: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure RButtonChange(Sender: TObject);
    procedure SetGameParam(WGame, HGame, CBGame:Integer);
  private
    FColBomGame: Integer;
    FHeigthGame: Integer;
    FWidthGame: Integer;

  public
    property WidthGame:Integer read FWidthGame;
    property HeigthGame:Integer read FHeigthGame;
    property ColBomGame:Integer read FColBomGame;
    constructor Create(TheOwner: TComponent; WGame,HGame,CBGame:Integer);
  end;

//var
  //SpSettingForm: TSpSettingForm;

const
  //Новичок
  HeigthGameNv:Integer = 8;
  WidthGameNv:Integer = 8;
  ColBomGameNv:Integer = 10;
  //Специалист
  HeigthGameSp:Integer = 15;
  WidthGameSp:Integer = 15;
  ColBomGameSp:Integer = 40;
  //Эксперт
  HeigthGameExp:Integer = 16;
  WidthGameExp:Integer = 25;
  ColBomGameExp:Integer = 80;

implementation

{$R *.lfm}

{ TSpSettingForm }

procedure TSpSettingForm.RButtonChange(Sender: TObject);
begin
  with TRadioButton(Sender) do
    begin
      if (Tag = 1) and Checked then SetGameParam(WidthGameNv, HeigthGameNv, ColBomGameNv);
      if (Tag = 2) and Checked then SetGameParam(WidthGameSp, HeigthGameSp, ColBomGameSp);
      if (Tag = 3) and Checked then SetGameParam(WidthGameExp, HeigthGameExp, ColBomGameExp);
      if (Tag = 4) and Checked then SetGameParam(WidthEdit.Value, HeigthEdit.Value, ColBombEdit.Value);
    end;
end;

procedure TSpSettingForm.Button1Click(Sender: TObject);
begin
  FColBomGame:= ColBombEdit.Value;
  FHeigthGame:= HeigthEdit.Value;
  FWidthGame:= WidthEdit.Value;
end;

procedure TSpSettingForm.SetGameParam(WGame, HGame, CBGame: Integer);
begin
  HeigthEdit.Value:= HGame;
  ColBombEdit.Value:= CBGame;
  WidthEdit.Value:= WGame;
  HeigthEdit.Enabled:=RButtonMain.Checked;
  WidthEdit.Enabled:=RButtonMain.Checked;
  ColBombEdit.Enabled:=RButtonMain.Checked;
end;

constructor TSpSettingForm.Create(TheOwner: TComponent; WGame, HGame, CBGame: Integer);
begin
  inherited Create(TheOwner);
  if (HGame = HeigthGameNv) and (WGame = WidthGameNv) and (CBGame = ColBomGameNv) then RButtonNv.Checked:=True;
  if (HGame = HeigthGameSp) and (WGame = WidthGameSp) and (CBGame = ColBomGameSp) then RButtonSp.Checked:=True;
  if (HGame = HeigthGameExp) and (WGame = WidthGameExp) and (CBGame = ColBomGameExp) then RButtonExp.Checked:=True;
  if not((HGame = HeigthGameNv) and (WGame = WidthGameNv) and (CBGame = ColBomGameNv)) and
     not((HGame = HeigthGameSp) and (WGame = WidthGameSp) and (CBGame = ColBomGameSp)) and
     not((HGame = HeigthGameExp) and (WGame = WidthGameExp) and (CBGame = ColBomGameExp)) then RButtonMain.Checked:=True;
  SetGameParam(WGame, HGame, CBGame);
end;

end.

