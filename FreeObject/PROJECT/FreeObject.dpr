program FreeObject;

uses
  Vcl.Forms,
  Main.Form in '..\SOURCE\Main.Form.pas' {MainForm},
  uCity in '..\SOURCE\uCity.pas',
  uDataManipulation in '..\SOURCE\uDataManipulation.pas';

{$R *.res}

begin
  //��� ����������� ������ ������, ���� ��� ����
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
