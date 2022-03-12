unit PlayingFieldUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Buttons, Controls, ExtCtrls, Forms;

type

  TSPButtionState = (spbFlag, spbQest, spbExcPoint, spbNoFlag);

  { TSPFlagButtion }

  TSPFlagButtion = class(TCustomSpeedButton)
  private
    FBomb: boolean;
    FColBombAround: Integer;
    FFlag: TSPButtionState;
    FOpen: Boolean;
    FNom: Integer;
    procedure SetFlag(AValue: TSPButtionState);
  public
    property Nomber: integer read FNom;
    property Bomb: boolean read FBomb write FBomb;
    property ColBombAround: Integer read FColBombAround write FColBombAround;
    property Open: Boolean read FOpen;
    property Flag:TSPButtionState read FFlag;
    procedure SetNextFlag;
    procedure SetNoFlag;
    procedure OpenButtion;
    procedure IncColBombArround;
  published
    constructor Create(AOwner:TComponent); override;
    constructor Create(AOwner:TComponent; Nom:Integer);
  end;

  { TPlayingField }

  TPlayingField = class(TCustomPanel)
  private
    FTimer:TTimer;
    FGameTime:LongInt;
    FOnTimeClock:TNotifyEvent;
    ButtonHeight: Integer;
    ButtonWidth: Integer;
    FImgList: TImageList;
    FPlayingFieldList: TList;
    FWGame: Integer;
    FHGame: Integer;
    FColBomb: Integer;
    FColFlag: Integer;
    FGameOver:Boolean;
    FGameVictory:Boolean;
    FOnGameOver:TNotifyEvent;
    FOnColFlag:TNotifyEvent;
    procedure DoOnTimeClock; dynamic;
    procedure DoOnGameOver; dynamic;
    procedure DoOnColFlag; dynamic;
    procedure FullInGameButtion();
    procedure FullGameBomb();
    procedure FullGameNumbers();
    procedure CheckGameOver;
    procedure DestroyAllButtion;
    procedure GameOver(Nom:Integer);
    procedure OpenClearButtion(Nom:Integer);
    procedure OpenAroundNumber(Nom:Integer);
    procedure CreateNewButton(IntW,IntH,Nbomb:Integer);
    procedure PlayButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetTime(Sender: TObject);
    procedure SetImgList(AValue: TImageList);
  public
    procedure CreateNewGame();
    property ImgList:TImageList read FImgList write SetImgList;
    property GameTime:Integer read FGameTime;
    property ColBomb:Integer read FColBomb;
    property ColFlag:Integer read FColFlag;
    property GameViktory:Boolean read FGameVictory;
    property OnTimeClock: TNotifyEvent read FOnTimeClock write FOnTimeClock;
    property OnGameOver: TNotifyEvent read FOnGameOver write FOnGameOver;
    property OnColFlag: TNotifyEvent read FOnColFlag write FOnColFlag;
    constructor Create(AOwner: TComponent); override;
    constructor Create(AOwner: TComponent; WidthGame,HeightGame,IntBomb:Integer);
    destructor Destroy; override;
  end;

implementation

{ TSPFlagButtion }

procedure TSPFlagButtion.SetFlag(AValue: TSPButtionState);
begin
  FFlag := AValue;
  if AValue = spbFlag then ImageIndex := 12;
  if AValue = spbQest then ImageIndex := 13;
  if AValue = spbExcPoint then ImageIndex := 14;
  if AValue = spbNoFlag then ImageIndex := 0;
end;

procedure TSPFlagButtion.SetNextFlag;
  var Value:TSPButtionState;
begin
  if FFlag = spbNoFlag then Value := spbFlag;
  if FFlag = spbFlag then Value := spbExcPoint;
  //if FFlag = spbFlag then Value := spbQest;
  //if FFlag = spbQest then Value := spbExcPoint;
  if FFlag = spbExcPoint then Value := spbNoFlag;
  SetFlag(Value);
end;

procedure TSPFlagButtion.SetNoFlag;
begin
  FFlag := spbNoFlag;
  ImageIndex := 0;
end;

procedure TSPFlagButtion.OpenButtion;
begin
  if (FFlag = spbNoFlag) and not FOpen then
    begin
      FOpen := True;
      if FBomb then ImageIndex := 10;
      if not FBomb and (FColBombAround > 0) then ImageIndex := FColBombAround;
      if not FBomb and (FColBombAround = 0) then
        begin
          ImageIndex := -1;
          Enabled := False;
        end;
    end;
end;

procedure TSPFlagButtion.IncColBombArround;
begin
  Inc(FColBombAround);
end;

constructor TSPFlagButtion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent:= AOwner as TWinControl;
  Bomb  := False;
  FFlag :=  spbNoFlag;
  FOpen := False;
  ImageIndex := 0;
end;

constructor TSPFlagButtion.Create(AOwner: TComponent; Nom: Integer);
begin
  inherited Create(AOwner);
  Parent:= AOwner as TWinControl;
  Bomb  := False;
  FFlag :=  spbNoFlag;
  FOpen := False;
  FNom  := Nom;
  ImageIndex := 0;
end;

{TPlayingField }

procedure TPlayingField.CreateNewGame();
begin
  FGameTime:= 0;
  FColFlag := 0;
  FGameOver:= False;
  FGameVictory := False;
  DestroyAllButtion;
  FPlayingFieldList.Clear;
  FullInGameButtion();
  FullGameBomb();
  FullGameNumbers();
  DoOnColFlag;
  FTimer.Enabled:=True;
end;

procedure TPlayingField.CreateNewButton(IntW,IntH,Nbomb:Integer);
  var
    Sb: TSPFlagButtion;
begin
  Sb := TSPFlagButtion.Create(Self, Nbomb);
  Sb.Images := FImgList;
  Sb.ImageIndex := 0;
  Sb.Height := ButtonHeight;
  Sb.Width := ButtonWidth;
  Sb.Left := 2+(IntW-1)*ButtonWidth;
  Sb.Top := 2+(IntH-1)*ButtonHeight;
  Sb.OnMouseUp := @PlayButtonMouseUp;
  FPlayingFieldList.Add(Sb);
end;

procedure TPlayingField.PlayButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FGameOver then Exit;
  with (Sender as TSPFlagButtion) do
    begin
      if (Button = mbRight) and not Open then
        begin
          SetNextFlag;
          CheckGameOver;
        end;
      if Button = mbLeft then
        begin
          if Bomb and (Flag = spbNoFlag) then
            begin
              OpenButtion;
              GameOver((Sender as TSPFlagButtion).Nomber);
            end;
          if not Bomb and (Flag = spbNoFlag) then
            begin
              if Open and (ColBombAround > 0) then OpenAroundNumber((Sender as TSPFlagButtion).Nomber);
              if not Open and (ColBombAround > 0) then OpenButtion;
              if (ColBombAround = 0) then OpenClearButtion((Sender as TSPFlagButtion).Nomber);
              CheckGameOver;
            end;
        end;
    end;
end;

procedure TPlayingField.SetImgList(AValue: TImageList);
  var i:Integer;
begin
  if FImgList=AValue then Exit;
  FImgList:=AValue;
  for i:=0 to FPlayingFieldList.Count - 1 do
    begin
      TSPFlagButtion(FPlayingFieldList[i]).Images := AValue;
    end;
end;

procedure TPlayingField.DoOnTimeClock;
begin
  if Assigned(FOnTimeClock) then FOnTimeClock(Self);
end;

procedure TPlayingField.DoOnGameOver;
begin
  if Assigned(FOnGameOver) then FOnGameOver(Self);
end;

procedure TPlayingField.DoOnColFlag;
begin
  if Assigned(FOnColFlag) then FOnColFlag(Self);
end;

procedure TPlayingField.FullInGameButtion();
  var H,W,i: integer;
begin
  i := 0;
  for H:=1 to FHGame do
    for W:=1 to FWGame do
      begin
        CreateNewButton(W,H,i);
        Inc(i);
      end;
end;

{// Вариант заполнения игрового поля бомбами
procedure TPlayingField.FullGameBomb();
  var r,i: Integer;
begin
  i := FColBomb;
  Randomize;
  repeat
    begin
      r := Random(FWGame*FHGame-1);
      // Углы игрового поля пусть будут без бомб :)
      if not TSPFlagButtion(FPlayingFieldList[r]).Bomb and (r<>0) and (r<>(FWGame*FHGame-1))
           and (r<>(FWGame*FHGame-FWGame)) and (r<>(FWGame-1)) Then
        begin
          Dec(i);
          TSPFlagButtion(FPlayingFieldList[r]).Bomb := True;
          //TSPFlagButtion(FPlayingFieldList[r]).ImageIndex:=9;
        end;
    end;
  until i = 0;
end;}

procedure TPlayingField.FullGameBomb();
  var i: Integer;

  procedure ReplaceBomb(y:Integer);
    var r:Integer;
        bl:Boolean;
  begin
    r := Random(FWGame*FHGame-1);
    bl := TSPFlagButtion(FPlayingFieldList[y]).Bomb;
    TSPFlagButtion(FPlayingFieldList[y]).Bomb := TSPFlagButtion(FPlayingFieldList[r]).Bomb;
    TSPFlagButtion(FPlayingFieldList[r]).Bomb := bl;
  end;

begin
  Randomize;
  for i := 0 to FColBomb-1 do TSPFlagButtion(FPlayingFieldList[i]).Bomb := True;
  for i := 0 to FColBomb-1 do ReplaceBomb(i);
  for i := 0 to (FHGame * FWGame) - 1 do ReplaceBomb(i);
  // Углы игрового поля пусть будут без бомб :)
  while TSPFlagButtion(FPlayingFieldList[0]).Bomb do ReplaceBomb(0);
  while TSPFlagButtion(FPlayingFieldList[FWGame*FHGame-1]).Bomb do ReplaceBomb(FWGame*FHGame-1);
  while TSPFlagButtion(FPlayingFieldList[FWGame*FHGame-FWGame]).Bomb do ReplaceBomb(FWGame*FHGame-FWGame);
  while TSPFlagButtion(FPlayingFieldList[FWGame-1]).Bomb do ReplaceBomb(FWGame-1);
end;

procedure TPlayingField.FullGameNumbers();
  var i:integer;
begin
  for i := 0 to (FHGame * FWGame) - 1 do
  if TSPFlagButtion(FPlayingFieldList[i]).Bomb then
    begin
      if ((i mod FWGame) > 0) then TSPFlagButtion(FPlayingFieldList[i-1]).IncColBombArround;
      if (i > FWGame) and (((i - FWGame) mod FWGame) > 0) then TSPFlagButtion(FPlayingFieldList[i-FWGame-1]).IncColBombArround;
      if ((i + 1) > FWGame) then TSPFlagButtion(FPlayingFieldList[i-FWGame]).IncColBombArround;
      if ((i + 1) > FWGame) and (((i + 1) mod FWGame) <> 0) then TSPFlagButtion(FPlayingFieldList[i-FWGame+1]).IncColBombArround;
      if (((i + 1) mod FWGame) <> 0) then TSPFlagButtion(FPlayingFieldList[i+1]).IncColBombArround;
      if (i < (FWGame*FHGame-FWGame-1)) and (((i + 1) mod FWGame) <> 0) then TSPFlagButtion(FPlayingFieldList[i+FWGame+1]).IncColBombArround;
      if (i < (FHGame*FWGame-FWGame)) then TSPFlagButtion(FPlayingFieldList[i+FWGame]).IncColBombArround;
      if (i < (FHGame*FWGame-FWGame)) and ((i mod FWGame) > 0) then TSPFlagButtion(FPlayingFieldList[i+FWGame-1]).IncColBombArround;
      //TSPFlagButtion(FPlayingFieldList[i]).ImageIndex:=9;
    end;
 end;

procedure TPlayingField.CheckGameOver;
  var i,Opened,CFlag:Integer;
begin
  Opened := 0;
  CFlag := 0;
  if FGameOver then Exit;
  for i := 0 to FPlayingFieldList.Count - 1 do
    with TSPFlagButtion(FPlayingFieldList[(i)]) do
      begin
        if Open then Inc(Opened);
        if Flag = spbFlag then Inc(CFlag);
      end;
  //-------------------
  if not (FColFlag = CFlag) then
    begin
      FColFlag := CFlag;
      DoOnColFlag;
    end;
  //--------------------
  if (CFlag = FColBomb) and ((Opened + CFlag) = (FWGame*FHGame)) then
    begin
      FTimer.Enabled:=False;
      FGameOver := True;
      FGameVictory := True;
      DoOnGameOver;
    end;
end;

procedure TPlayingField.OpenClearButtion(Nom:Integer);
 var  SbList:TList;
      n:Integer;

  procedure OpenButtionX(x:Integer);
  begin
    with TSPFlagButtion(FPlayingFieldList[(x)]) do
      begin
        if Bomb and (Flag = spbNoFlag) then
          begin
            OpenButtion;
            GameOver(TSPFlagButtion(FPlayingFieldList[(x)]).Nomber);
            SbList.Clear;
          end;
        if not Bomb and (Flag = spbNoFlag) and (ColBombAround > 0) then OpenButtion;
        if not Bomb and (Flag = spbNoFlag) and (ColBombAround = 0) and Enabled and
             (SBlist.IndexOf(FPlayingFieldList[x]) = -1) then SbList.Add(FPlayingFieldList[x]);
      end;
  end;

begin
  SbList := TList.Create;
  SbList.Capacity := FWGame*FHGame;
  SbList.Add(FPlayingFieldList[Nom]);
  repeat
    begin
      TSPFlagButtion(SbList[0]).OpenButtion;
      n := TSPFlagButtion(SbList[0]).Nomber;
      if ((n mod FWGame) > 0) then OpenButtionX(n-1);
      if (n > FWGame) and (((n - FWGame) mod FWGame) > 0) then OpenButtionX(n-FWGame-1);
      if ((n + 1) > FWGame) then OpenButtionX(n-FWGame);
      if ((n + 1) > FWGame) and (((n + 1) mod FWGame) <> 0) then OpenButtionX(n-FWGame+1);
      if (((n + 1) mod FWGame) <> 0) then OpenButtionX(n+1);
      if (n < (FWGame*FHGame-FWGame-1)) and (((n + 1) mod FWGame) <> 0) then OpenButtionX(n+FWGame+1);
      if (n < (FHGame*FWGame-FWGame)) then OpenButtionX(n+FWGame);
      if (n < (FHGame*FWGame-FWGame)) and ((n mod FWGame) > 0) then OpenButtionX(n+FWGame-1);
      if SbList.Count > 0 then SbList.Delete(0);
    end;
  until SbList.Count = 0;
  SbList.Free;
end;

procedure TPlayingField.GameOver(Nom:Integer);
  var i:Integer;
begin
  FTimer.Enabled:=False;
  FGameOver := True;
  for i := 0 to FPlayingFieldList.Count - 1 do
    with TSPFlagButtion(FPlayingFieldList[(i)]) do
      if not Open then
        begin
          if (Flag = spbQest) or (Flag = spbExcPoint) then SetNoFlag;
          OpenButtion;
          if not Bomb and (Flag = spbFlag) then ImageIndex:=11;
          if not (Nomber = Nom) and Bomb and (Flag = spbNoFlag) then ImageIndex:=9;
        end;
  DoOnGameOver;
end;

procedure TPlayingField.OpenAroundNumber(Nom: Integer);
  var Refusal: Boolean;
      CFlag:Integer;

  procedure ExaminationButtion(n:Integer);
  begin
    with TSPFlagButtion(FPlayingFieldList[n]) do
      begin
        if Flag = spbFlag then Inc(CFlag);
        if (Flag = spbQest) or (Flag = spbExcPoint) then Refusal := True;
      end;
  end;

begin
  Refusal := False;
  CFlag := 0;
  if ((Nom mod FWGame) > 0) then ExaminationButtion(Nom-1);
  if (Nom > FWGame) and (((Nom - FWGame) mod FWGame) > 0) then ExaminationButtion(Nom-FWGame-1);
  if ((Nom + 1) > FWGame) then ExaminationButtion(Nom-FWGame);
  if ((Nom + 1) > FWGame) and (((Nom + 1) mod FWGame) <> 0) then ExaminationButtion(Nom-FWGame+1);
  if (((Nom + 1) mod FWGame) <> 0) then ExaminationButtion(Nom+1);
  if (Nom < (FWGame*FHGame-FWGame-1)) and (((Nom + 1) mod FWGame) <> 0) then ExaminationButtion(Nom+FWGame+1);
  if (Nom < (FHGame*FWGame-FWGame)) then ExaminationButtion(Nom+FWGame);
  if (Nom < (FHGame*FWGame-FWGame)) and ((Nom mod FWGame) > 0) then ExaminationButtion(Nom+FWGame-1);
  if not Refusal and (TSPFlagButtion(FPlayingFieldList[Nom]).ColBombAround = CFlag) then OpenClearButtion(Nom);
end;

constructor TPlayingField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent:= AOwner as TWinControl;
  DoubleBuffered := True;
  Caption := '';
  //Align := alClient;
  BevelInner := bvLowered;
  BevelOuter := bvNone;
  ButtonHeight := 22;
  ButtonWidth := 23;
  FColFlag := 0;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 100;
  FTimer.OnTimer:=@SetTime;
  FTimer.Enabled:=True;
  //FPlayingFieldList := TList.Create;
  //FPlayingFieldList.Capacity := WidthGame*HeightGame;
end;

constructor TPlayingField.Create(AOwner: TComponent; WidthGame,HeightGame,IntBomb:Integer);
begin
  inherited Create(AOwner);
  Parent:= AOwner as TWinControl;
  DoubleBuffered := True;
  Caption := '';
  //Align := alClient;
  BevelInner := bvLowered;
  BevelOuter := bvNone;
  ButtonHeight := 22;
  ButtonWidth := 23;
  FWGame:= WidthGame;
  FHGame:= HeightGame;
  FColBomb := IntBomb;
  FColFlag := 0;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 100;
  FTimer.OnTimer:=@SetTime;
  FTimer.Enabled:=True;
  FPlayingFieldList := TList.Create;
  FPlayingFieldList.Capacity := WidthGame*HeightGame;
end;

procedure TPlayingField.SetTime(Sender: TObject);
begin
  Inc(FGameTime);
  DoOnTimeClock;
end;

procedure TPlayingField.DestroyAllButtion;
 var i:Integer;
begin
  for i := 0 to FPlayingFieldList.Count - 1 do
    begin
      TSPFlagButtion(FPlayingFieldList[i]).Destroy;
    end;
end;

destructor TPlayingField.Destroy;
begin
  DestroyAllButtion;
  FPlayingFieldList.Free;
  FTimer.Destroy;
  inherited Destroy;
end;

end.

