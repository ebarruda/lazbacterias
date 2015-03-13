{
 LazBacterias versao 1.0.1
 Implementado no Lazarus por: Ericson Benjamim
 Contato: ericsonbenjamim@yahoo.com.br
 Data: 03 de dezembro de 2009
 Atualizado: 06 de dezembro de 2009
 Licenca: GPL
}
unit LazBacterias_FormPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    ButtonMaisLento: TButton;
    ButtonMaisRapido: TButton;
    ButtonSobre: TButton;
    ButtonNovoJogo: TButton;
    ButtonGeracao: TButton;
    ButtonSair: TButton;
    ColorButtonFundo: TColorButton;
    ColorButtonBacteriaViva: TColorButton;
    ColorButtonBacteriaMorta: TColorButton;
    ComboBoxForma: TComboBox;
    ComboBoxPredefinicao: TComboBox;
    LabelTextoGeracao: TLabel;
    LabelGeracao: TLabel;
    PanelCultura: TPanel;
    TimerGeracao: TTimer;
    procedure ButtonGeracaoClick(Sender: TObject);
    procedure ButtonMaisLentoClick(Sender: TObject);
    procedure ButtonMaisRapidoClick(Sender: TObject);
    procedure ButtonNovoJogoClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
    procedure ButtonSobreClick(Sender: TObject);
    procedure ColorButtonBacteriaMortaColorChanged(Sender: TObject);
    procedure ColorButtonBacteriaVivaColorChanged(Sender: TObject);
    procedure ColorButtonFundoColorChanged(Sender: TObject);
    procedure ComboBoxFormaChange(Sender: TObject);
    procedure ComboBoxPredefinicaoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerGeracaoTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    CorFundo: TColor;
    CorBacteriaViva: TColor;
    CorBacteriaMorta: TColor;
    Geracao: LongInt;
    Intervalo: LongInt;
    Incremento: LongInt;
    EspacoVertical, EspacoHorizontal: Word;
    Altura, Largura: Word;
    MaxLinha, MaxColuna: Word;
    procedure ShapeBacteriaClick(Sender: TObject);
  end;

  TShapeBacteria = class(TShape)
  private
    { private declarations }
  public
    { public declarations }
    Coluna: SmallInt;
    Linha: SmallInt;
  end;

var
  FormPrincipal: TFormPrincipal;
  ShapeBacteria: array of array of TShapeBacteria; // vetor bidimensional dinamico
  ProximaGeracaoBacteria: array of array of boolean; // vetor bidimensional dinamico

implementation

uses
  LazBacterias_FormSobre;

{ TFormPrincipal }

procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
  X, Y: SmallInt;
begin
  // Centraliza Form na tela
  Left := (Screen.Width  div 2) - (Width div 2);
  Top  := (Screen.Height div 2) - (Height div 2);
  //
  Altura           := 10;
  Largura          := 10;
  EspacoVertical   := 5;
  EspacoHorizontal := 5;
  MaxLinha         := 25;
  MaxColuna        := 40;
  Intervalo        := 500;
  Incremento       := 50;
  CorFundo         := clGreen;
  CorBacteriaViva  := clYellow;
  CorBacteriaMorta := clSkyBlue;
  //
  // Configura o tamanho da cultura de
  // bacterias usando vetor dinamico
  //
  SetLength(ShapeBacteria, MaxColuna, MaxLinha);
  SetLength(ProximaGeracaoBacteria, MaxColuna, MaxLinha);
  //
  // Cria os pontos onde as bacterias podem viver
  //
  Y := 0;
  for LinhaBacteria := 0 to MaxLinha - 1 do begin
    Inc(Y, Altura + EspacoVertical);
    X := 0;
    for ColunaBacteria := 0 to MaxColuna - 1 do begin
      Inc(X, Largura + EspacoHorizontal);
      ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := false;
      ShapeBacteria[ColunaBacteria, LinhaBacteria]          := TShapeBacteria.Create(PanelCultura);
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do begin
        Visible     := false;
        parent      := PanelCultura;
        Shape       := stEllipse;
        Left        := X;
        Top         := Y;
        Height      := Altura;
        Width       := Largura;
        Pen.Style   := psClear;
        Brush.Color := CorBacteriaMorta;
        Coluna      := ColunaBacteria;
        Linha       := LinhaBacteria;
        OnClick     := @ShapeBacteriaClick;
      end;
    end;
  end;
  ButtonGeracao.Enabled := false;
end;

procedure TFormPrincipal.ButtonSobreClick(Sender: TObject);
begin
  FormSobre.ShowModal;
end;

procedure TFormPrincipal.ButtonNovoJogoClick(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
begin
  //
  // Novo jogo
  //
  TimerGeracao.Enabled           := false;
  ButtonGeracao.Enabled          := true;
  ComboBoxPredefinicao.Enabled   := true;
  ComboBoxPredefinicao.ItemIndex := -1;
  Geracao                        := 0;
  LabelGeracao.Caption           := '0';
  PanelCultura.Color             := CorFundo;
  ButtonGeracao.Caption          := 'Iniciar Geração';
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do begin
        Visible                                               := true;
        Brush.Color                                           := CorBacteriaMorta;
        ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := false;
      end;
end;

procedure TFormPrincipal.ButtonSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.ButtonGeracaoClick(Sender: TObject);
begin
  if ButtonGeracao.Caption = 'Iniciar Geração' then begin
    //
    // Inicia o avanco das geracoes
    //
    TimerGeracao.Enabled         := true;
    ComboBoxPredefinicao.Enabled := false;
    ButtonGeracao.Caption        := 'Pausar Geração';
  end else begin
    if ButtonGeracao.Caption = 'Pausar Geração' then begin
      //
      // Pausa o avanco das geracoes
      //
      TimerGeracao.Enabled         := false;
      ComboBoxPredefinicao.Enabled := true;
      ButtonGeracao.Caption        := 'Continuar Geração';
    end else begin
      //
      // Continua o avanco das geracoes
      //
      TimerGeracao.Enabled         := true;
      ComboBoxPredefinicao.Enabled := false;
      ButtonGeracao.Caption        := 'Pausar Geração';
    end;
  end;
end;

procedure TFormPrincipal.ButtonMaisLentoClick(Sender: TObject);
begin
  Inc(Intervalo, Incremento);
  if Intervalo > 10000 then begin
    if ButtonMaisLento.Enabled then ButtonMaisLento.Enabled := false;
    Intervalo := 10000;
  end;
  if not ButtonMaisRapido.Enabled then ButtonMaisRapido.Enabled := true;
  TimerGeracao.Interval := Intervalo
end;

procedure TFormPrincipal.ButtonMaisRapidoClick(Sender: TObject);
begin
  Dec(Intervalo, Incremento);
  if Intervalo < 50 then begin
    if ButtonMaisRapido.Enabled then ButtonMaisRapido.Enabled := false;
    Intervalo := 50;
  end;
  if not ButtonMaisLento.Enabled then ButtonMaisLento.Enabled := true;
  TimerGeracao.Interval := Intervalo
end;

procedure TFormPrincipal.ShapeBacteriaClick(Sender: TObject);
begin
  with TShapeBacteria(Sender) do
    if not TimerGeracao.Enabled and ButtonGeracao.Enabled then
    //
    // Somente altera o estado do ponto se a geracao estiver parada/pausada
    //
    if Brush.Color = CorBacteriaMorta then begin
      // Acrescenta uma bacteria
      Brush.Color                           := CorBacteriaViva;
      ProximaGeracaoBacteria[Coluna, Linha] := true;
    end else begin
      if Brush.Color = CorBacteriaViva then begin
        // Remove uma bacteria
        Brush.Color                           := CorBacteriaMorta;
        ProximaGeracaoBacteria[Coluna, Linha] := false;
      end;
    end;
end;

procedure TFormPrincipal.TimerGeracaoTimer(Sender: TObject);
var
  BacteriasVivas: word;
  LinhaBacteria, ColunaBacteria: SmallInt;
  VizinhosVivos: byte;
begin
  //
  // Aplica configuracao na geracao anterior
  //
  if Geracao > 0 then
    for LinhaBacteria := 0 to MaxLinha - 1 do
      for ColunaBacteria := 0 to MaxColuna - 1 do
        if ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] then
          ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color := CorBacteriaViva
        else
          ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color := CorBacteriaMorta;
  //
  // Verifica todas as bacterias da cultura
  //
  Inc(Geracao);
  BacteriasVivas       := 0;
  LabelGeracao.Caption := IntToStr(Geracao);
  //
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do begin
        VizinhosVivos  := 0;
        //
        // Configuracao dos Vizinhos
        //
        // +----+----+----+
        // | 01 | 02 | 03 |
        // +----+----+----+
        // | 04 | 00 | 05 |
        // +----+----+----+
        // | 06 | 07 | 08 |
        // +----+----+----+
        //
        // Primeiro (1º) vizinho
        //
        if ((ColunaBacteria - 1) >= 0) and ((LinhaBacteria - 1) >= 0) then
          if ShapeBacteria[ColunaBacteria - 1, LinhaBacteria - 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Segundo (2º) vizinho
        //
        if ((LinhaBacteria - 1) >= 0) then
          if ShapeBacteria[ColunaBacteria, LinhaBacteria - 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Terceiro (3º) vizinho
        //
        if ((ColunaBacteria + 1) < MaxColuna) and ((LinhaBacteria - 1) >= 0) then
          if ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Quarto (4º) vizinho
        //
        if ((ColunaBacteria - 1) >= 0) then
          if ShapeBacteria[ColunaBacteria - 1, LinhaBacteria].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Quinto (5º) vizinho
        //
        if ((ColunaBacteria + 1) < MaxColuna) then
          if ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Sexto (6º) vizinho
        //
        if ((ColunaBacteria - 1) >= 0) and ((LinhaBacteria + 1) < MaxLinha) then
          if ShapeBacteria[ColunaBacteria - 1, LinhaBacteria + 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Setimo (7º) vizinho
        //
        if ((LinhaBacteria + 1) < MaxLinha) then
          if ShapeBacteria[ColunaBacteria, LinhaBacteria + 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Oitavo (8º) vizinho
        //
        if ((ColunaBacteria + 1) < MaxColuna) and ((LinhaBacteria + 1) < MaxLinha) then
          if ShapeBacteria[ColunaBacteria + 1, LinhaBacteria + 1].Brush.Color = CorBacteriaViva then
            Inc(VizinhosVivos);
        //
        // Soma todas as bacterias vivas
        //
        BacteriasVivas := BacteriasVivas + VizinhosVivos;
        //
        // Aplica as regras do jogo
        //
        if ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color = CorBacteriaViva then begin
          //
          // Aplica as regras do jogo as bacterias vivas
          //
          if (VizinhosVivos < 2) or (VizinhosVivos > 3) then
            ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := false
          else
            ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := true;
        end else begin
          //
          // Aplica as regras do jogo aos pontos vazios
          //
          if (VizinhosVivos = 3) then
            ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := true;
        end;
      end;
  //
  // Verifica se ainda ha bacterias vivas
  //
  if BacteriasVivas = 0 then begin
    TimerGeracao.Enabled  := false;
    ButtonGeracao.Enabled := false;
    ButtonGeracao.Caption := 'Iniciar Geração';
    ShowMessage('Não há bactérias vivas! Você perdeu!');
  end;
end;

procedure TFormPrincipal.FormResize(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
  X, Y: SmallInt;
  NovoEspacoVertical, NovoEspacoHorizontal: Word;
  NovaAltura, NovaLargura: Word;
begin
  //
  // Redefine proporcionalmente todos os componentes ao redimensionar o form
  //
  PanelCultura.Width           := FormPrincipal.Width - 20;
  PanelCultura.Height          := FormPrincipal.Height - (480 - 395);
  ButtonNovoJogo.Top           := PanelCultura.Top + PanelCultura.Height + 10;
  ButtonGeracao.Top            := PanelCultura.Top + PanelCultura.Height + 10;
  ButtonMaisLento.Top          := PanelCultura.Top + PanelCultura.Height + 10;
  ButtonMaisRapido.Top         := PanelCultura.Top + PanelCultura.Height + 10;
  ButtonSobre.Top              := PanelCultura.Top + PanelCultura.Height + 10;
  ButtonSair.Top               := PanelCultura.Top + PanelCultura.Height + 10;
  LabelTextoGeracao.Top        := ButtonSair.Top + 30;
  LabelGeracao.Top             := ButtonSair.Top + 30;
  ColorButtonFundo.Top         := ButtonSair.Top + 30;
  ColorButtonBacteriaViva.Top  := ButtonSair.Top + 30;
  ColorButtonBacteriaMorta.Top := ButtonSair.Top + 30;
  ComboBoxPredefinicao.Top     := ButtonSair.Top + 30;
  ComboBoxForma.Top            := ButtonSair.Top + 30;
  //
  NovaAltura  := Round(Altura * (FormPrincipal.Height / 480));
  NovaLargura := Round(Largura * (FormPrincipal.Width / 640));
  //
  NovoEspacoVertical   := Round(EspacoVertical * (FormPrincipal.Height / 480));
  NovoEspacoHorizontal := Round(EspacoHorizontal * (FormPrincipal.Width / 640));
  //
  Y := 0;
  for LinhaBacteria := 0 to MaxLinha - 1 do begin
    Inc(Y, NovaAltura + NovoEspacoVertical);
    X := 0;
    for ColunaBacteria := 0 to MaxColuna - 1 do
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do begin
        Inc(X, NovaLargura + NovoEspacoHorizontal);
        Left   := X;
        Top    := Y;
        Height := NovaAltura;
        Width  := NovaLargura;
      end;
  end;
end;

procedure TFormPrincipal.ColorButtonBacteriaMortaColorChanged(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
begin
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do
        if Brush.Color = CorBacteriaMorta then Brush.Color := ColorButtonBacteriaMorta.ButtonColor;
  CorBacteriaMorta := ColorButtonBacteriaMorta.ButtonColor;
end;

procedure TFormPrincipal.ColorButtonBacteriaVivaColorChanged(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
begin
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do
      with ShapeBacteria[ColunaBacteria, LinhaBacteria] do
        if Brush.Color = CorBacteriaViva then Brush.Color := ColorButtonBacteriaViva.ButtonColor;
  CorBacteriaViva := ColorButtonBacteriaViva.ButtonColor;
end;

procedure TFormPrincipal.ColorButtonFundoColorChanged(Sender: TObject);
begin
  CorFundo           := ColorButtonFundo.ButtonColor;
  PanelCultura.Color := CorFundo;
end;

procedure TFormPrincipal.ComboBoxPredefinicaoChange(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
begin
  // Limpar
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do begin
      ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color := CorBacteriaMorta;
      ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria]    := false;
    end;
  case ComboBoxPredefinicao.ItemIndex of
    1: begin
         //
         // Planador
         //
         ColunaBacteria := 20;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria,     LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
       end;
    2: begin
         //
         // Pequena Explosão
         //
         ColunaBacteria := 20;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria,     LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria - 1, LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria,     LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria - 1, LinhaBacteria + 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria + 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria,     LinhaBacteria + 3].Brush.Color := CorBacteriaViva;
       end;
    3: begin
         //
         // Explosão
         //
         ColunaBacteria := 18;
         LinhaBacteria  := 10;
         //
         ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria + 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria + 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria + 4].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria + 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria + 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria + 4].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria + 4].Brush.Color := CorBacteriaViva;
       end;
    4: begin
         //
         // Linha com 10 bactérias
         //
         ColunaBacteria := 15;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria,     LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 3, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 5, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 6, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 7, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 8, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 9, LinhaBacteria].Brush.Color := CorBacteriaViva;
       end;
    5: begin
         //
         // Espaçonave leve
         //
         ColunaBacteria := 15;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria,     LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria,     LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 3, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 3, LinhaBacteria].Brush.Color     := CorBacteriaViva;
       end;
    6: begin
         //
         // Copo
         //
         ColunaBacteria := 15;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 5].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 5].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 4, LinhaBacteria - 5].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 5, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 5, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 5, LinhaBacteria - 5].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 6, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 6, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 6, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
       end;
    7: begin
         //
         // Floco de neve
         //
         ColunaBacteria := 20;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
       end;
    8: begin
         //
         // Pulsar
         //
         ColunaBacteria := 20;
         LinhaBacteria  := 15;
         //
         ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria + 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria - 5].Brush.Color := CorBacteriaViva;
         //
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 1].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 2].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 3].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria - 4].Brush.Color := CorBacteriaViva;
       end;
    9: begin
         //
         // Piscador
         //
         ColunaBacteria := 20;
         LinhaBacteria  := 12;
         //
         ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color     := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 1, LinhaBacteria].Brush.Color := CorBacteriaViva;
         ShapeBacteria[ColunaBacteria + 2, LinhaBacteria].Brush.Color := CorBacteriaViva;
       end;
  end;
  for LinhaBacteria := 0 to MaxLinha - 1 do
    for ColunaBacteria := 0 to MaxColuna - 1 do begin
      if ShapeBacteria[ColunaBacteria, LinhaBacteria].Brush.Color = CorBacteriaViva then
        ProximaGeracaoBacteria[ColunaBacteria, LinhaBacteria] := true;
    end;
end;

procedure TFormPrincipal.ComboBoxFormaChange(Sender: TObject);
var
  LinhaBacteria, ColunaBacteria: SmallInt;
begin
  case ComboBoxForma.ItemIndex of
    0: for LinhaBacteria := 0 to MaxLinha - 1 do
         for ColunaBacteria := 0 to MaxColuna - 1 do
           ShapeBacteria[ColunaBacteria, LinhaBacteria].Shape := stEllipse;
    1: for LinhaBacteria := 0 to MaxLinha - 1 do
         for ColunaBacteria := 0 to MaxColuna - 1 do
           ShapeBacteria[ColunaBacteria, LinhaBacteria].Shape := stRectangle;
  end;
end;

initialization
  {$I LazBacterias_FormPrincipal.lrs}

end.

