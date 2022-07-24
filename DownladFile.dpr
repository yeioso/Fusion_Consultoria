program DownladFile;

uses
  Vcl.Forms,
  Form_Main in 'Form_Main.pas' {FrMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrMain, FrMain);
  Application.Run;
end.
