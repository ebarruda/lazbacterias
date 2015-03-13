{
 LazBacterias versao 1.0.1
 Implementado no Lazarus por: Ericson Benjamim
 Contato: ericsonbenjamim@yahoo.com.br
 Data: 03 de dezembro de 2009
 Atualizado: 06 de dezembro de 2009
 Licenca: GPL
}
unit LazBacterias_FormSobre;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type

  { TFormSobre }

  TFormSobre = class(TForm)
    BitBtn1: TBitBtn;
    ImageBacteria: TImage;
    MemoSobre: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormSobre: TFormSobre;

implementation

{ TFormSobre }

procedure TFormSobre.FormCreate(Sender: TObject);
begin
  // Centraliza Form na tela
  Left := (Screen.Width  div 2) - (Width div 2);
  Top  := (Screen.Height div 2) - (Height div 2);
end;

initialization
  {$I LazBacterias_FormSobre.lrs}

end.

