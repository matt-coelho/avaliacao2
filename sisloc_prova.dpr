program sisloc_prova;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Prova};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TProva, Prova);
  Application.Run;
end.
