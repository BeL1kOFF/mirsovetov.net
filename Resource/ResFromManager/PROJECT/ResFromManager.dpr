program ResFromManager;

{$R *.dres}

uses
  Vcl.Forms,
  Main.Form in '..\SOURCE\Main.Form.pas' {MainForm},
  uImage in '..\SOURCE\uImage.pas';

{$R *.res}

begin
  //��� ����������� ������ ������, ���� ��� ����
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
