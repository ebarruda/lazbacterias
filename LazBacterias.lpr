{
 LazBacterias versao 1.0.1
 Implementado no Lazarus por: Ericson Benjamim
 Contato: ericsonbenjamim@yahoo.com.br
 Data: 03 de dezembro de 2009
 Atualizado: 06 de dezembro de 2009
 Licenca: GPL
}
program LazBacterias;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LazBacterias_FormPrincipal, LResources, LazBacterias_FormSobre
  { you can add units after this };

{$IFDEF WINDOWS}{$R LazBacterias.rc}{$ENDIF}

begin
  {$I LazBacterias.lrs}
  Application.Initialize;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TFormSobre, FormSobre);
  Application.Run;
end.

