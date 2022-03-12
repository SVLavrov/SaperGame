unit GameResultFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, IniFiles;

type

  PGamePlayerResult = ^GamePlayerResult;

  GamePlayerResult = Record
    WidthGame,HeigthGame,ColBomb:Integer;
    GameTime:LongInt;
    NamePlayer:String[25];
  end;

  { TGameResultForm }

  TGameResultForm = class(TForm)
    Memo: TMemo;
  private

  public

  end;

  { TGameResult }

  TGameResult = class(TComponent)
  private
    FGameResult:TList;
    function GetGameRusult: String;
    procedure SetGameRusult(AValue: String);
    procedure SortingGameResult;
    function GetStPlayerResult(const GrPointer:PGamePlayerResult):String;
  public
    procedure ShowResultForm;
    procedure VerifyGameResult(WGame,HGame,CBomb:Integer; GTime:LongInt);
    property GameRusult:String read GetGameRusult write SetGameRusult;
    Destructor Destroy; override;
    constructor Create(AOwner:TComponent); override;
  end;

function GetStTime(const ATime:LongInt):String;

implementation

function GetStTime(const ATime: LongInt): String;
 var min,sek:Integer;
    stmin,stsek:String;
begin
  min := ATime div 600;
  sek := (ATime mod 600) div 10;
  stmin := IntToStr(min);
  if min<10 then stmin := '0' + stmin;
  stsek := IntToStr(sek);
  if sek<10 then stsek := '0' + stsek;
  Result:=stmin + ':' + stsek;
end;

{$R *.lfm}

{ TGameResult }

function TGameResult.GetGameRusult: String;
  var StX:TStringList;
   St:String;
   Gpr:PGamePlayerResult;
   i:integer;
begin
  StX := TStringList.Create;
  for i:=0 to FGameResult.Count-1 do
    begin
      Gpr := FGameResult[i];
      St := IntToStr(Gpr^.WidthGame) + '|';
      St := St + IntToStr(Gpr^.HeigthGame) + '|';
      St := St + IntToStr(Gpr^.ColBomb) + '|';
      St := St + IntToStr(Gpr^.GameTime) + '|';
      St := St + Gpr^.NamePlayer;
      StX.Add(St);
    end;
  Result := StX.Text;
  //Result := '';
  StX.Destroy;
end;

procedure TGameResult.SetGameRusult(AValue: String);
 var St:TStringList;
   StX:TStringList;
   Gpr:PGamePlayerResult;
   i:integer;
begin
  StX := TStringList.Create;
  StX.Text:=AValue;
  St := TStringList.Create;
  St.Delimiter:='|';
  for i := 0 to StX.Count - 1 do
    begin
      St.DelimitedText:=StX[i];
      New(Gpr);
      Gpr^.WidthGame := StrToInt(St[0]);
      Gpr^.HeigthGame := StrToInt(St[1]);
      Gpr^.ColBomb := StrToInt(St[2]);
      Gpr^.GameTime:= StrToInt(St[3]);
      Gpr^.NamePlayer := St[4];

      FGameResult.Add(Gpr);
    end;
  St.Destroy;
  StX.Destroy;
end;

procedure TGameResult.SortingGameResult;
 var i:integer;
   Ext:Boolean;
   GrpX,GrpY:PGamePlayerResult;
begin
  //Сортируем по количеству бомб
  if FGameResult.Count < 2 then Exit;
  repeat
    begin
      Ext := True;
      i := 0;
      repeat
        begin
          GrpX := PGamePlayerResult(FGameResult[i]);
          GrpY := PGamePlayerResult(FGameResult[i+1]);
          if GrpX^.ColBomb < GrpY^.ColBomb then
            begin
              FGameResult[i] := GrpY;
              FGameResult[i+1] := GrpX;
              Ext := False;
            end;
          if (GrpX^.WidthGame * GrpX^.HeigthGame) <
                       (GrpY^.WidthGame * GrpY^.HeigthGame) then
            begin
              FGameResult[i] := GrpY;
              FGameResult[i+1] := GrpX;
              Ext := False;
            end;
          Inc(i);
        end;
      until i = FGameResult.Count-1;
    end;
  until Ext;
end;

function TGameResult.GetStPlayerResult(const GrPointer: PGamePlayerResult): String;
 var St:String;
begin
  //------------
  St := ' ' + IntToStr(GrPointer^.WidthGame) + '/' +
              IntToStr(GrPointer^.HeigthGame);
  while Length(St) < 7 do St := St + ' ';
  Result := St + '|';
  //------------
  St := ' ' + IntToStr(GrPointer^.ColBomb);
  while Length(St) < 6 do St := St + ' ';
  Result := Result + St + '|';
  //------------
  St := ' ' + GetStTime(GrPointer^.GameTime);
  while Length(St) < 7 do St := St + ' ';
  Result := Result + St + '|';
  //------------
  Result := Result + ' ' + GrPointer^.NamePlayer;
end;

procedure TGameResult.ShowResultForm;
 var FGameResultForm:TGameResultForm;
   i:integer;
begin
  FGameResultForm := TGameResultForm.Create(Owner);
  for i:=0 to FGameResult.Count-1 do
    FGameResultForm.Memo.Lines.AddText(GetStPlayerResult(FGameResult[i]));
  FGameResultForm.ShowModal;
  FGameResultForm.Destroy;
end;

procedure TGameResult.VerifyGameResult(WGame, HGame, CBomb: Integer;
  GTime: LongInt);
  var St:String;
    Gpr:PGamePlayerResult;
    i,Wh,WhX,CBX,ix:Integer;

  function GetStNewNamePlayer:String;
   var StPl:String;
  begin
    StPl := 'Player';
    InputQuery('Поздравляем!','Введите ваше имя:',StPl);
    Result := StPl;
  end;

begin
  Wh := WGame * HGame;
  ix := -1;
  for i:=0 to FGameResult.Count-1 do
    begin
      Gpr := PGamePlayerResult(FGameResult[i]);
      WhX := Gpr^.WidthGame * Gpr^.HeigthGame;
      CBX := Gpr^.ColBomb;
      if (Wh = WhX) and (CBX = CBomb) then
        begin
          ix := i;
          Break;
        end;
    end;
  if ix = -1 then
    begin
      New(Gpr);
      Gpr^.WidthGame := WGame;
      Gpr^.HeigthGame := HGame;
      Gpr^.ColBomb := CBomb;
      Gpr^.GameTime:= GTime;
      Gpr^.NamePlayer := GetStNewNamePlayer;

      ix := FGameResult.Add(Gpr);
      SortingGameResult;
    end;
  //Gpr := PGamePlayerResult(FGameRusult[ix]);
  if Gpr^.GameTime > GTime then
    begin
      Gpr^.GameTime := GTime;
      Gpr^.NamePlayer := GetStNewNamePlayer;
    end;
end;

destructor TGameResult.Destroy;
 var i:Integer;
begin
  for i:= 0 to FGameResult.Count - 1 do
    Dispose(PGamePlayerResult(FGameResult[i]));
  FGameResult.Free;
  inherited Destroy;
end;

constructor TGameResult.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGameResult := TList.Create;
end;

end.

