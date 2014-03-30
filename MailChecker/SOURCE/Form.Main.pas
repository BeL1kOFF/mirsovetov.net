unit Form.Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient, IdPOP3,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdMessage, idMessageParts, IdAttachmentFile;

type
  TfrmMain = class(TForm)
    grpSettings: TGroupBox;
    lblAdress: TLabel;
    lblPass: TLabel;
    lblPop3: TLabel;
    lblPort: TLabel;
    edtAdress: TEdit;
    edtPass: TEdit;
    edtPop3: TEdit;
    edtPort: TEdit;
    tmrChecker: TTimer;
    grpCheck: TGroupBox;
    lblCheckAfter: TLabel;
    edtCheckAfter: TEdit;
    btnSetup: TButton;
    mmoResult: TMemo;
    IdPOP3: TIdPOP3;
    btnTest: TButton;
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    chkUseSSL: TCheckBox;
    cbSSLType: TComboBox;
    lbMessageInfo: TListBox;
    IdMessage1: TIdMessage;
    lst1: TListBox;
    procedure btnSetupClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure tmrCheckerTimer(Sender: TObject);
  private
    function StartTimer(T: TTimer; int: Integer): string;
    function CheckMail(IP: TIdPOP3; User, Pass, Host: string;
      Port: Integer): String;
    procedure SetupSSL;
    procedure SaveToLog(idMessage: TidMessage);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnSetupClick(Sender: TObject);
begin
  mmoResult.Lines.Add(StartTimer(tmrChecker, strToInt(edtCheckAfter.Text)));
end;

function TfrmMain.StartTimer(T:TTimer; int:Integer):string;
var
   sec:Integer; // ��������� ���������� ��� ������ � �� ���������� ����.
begin
   T.Enabled:=false; //��������� �������
   sec:=int*60000; // ���������� �������� ��������
   T.Interval:=sec; // ����� �������� ��������
   T.Enabled:=true; //��������� �������
   Result:='����� ����� ��������� ����� '+IntToStr(int)+' ���.'; // �������� ������� ����������
end;

procedure TfrmMain.tmrCheckerTimer(Sender: TObject);
begin
  mmoResult.Lines.add(CheckMail(IdPOP3,edtAdress.Text,edtPass.Text,edtPop3.Text,StrToInt(edtPort.Text)));
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
begin
  mmoResult.Lines.add(CheckMail(IdPOP3,edtAdress.Text,edtPass.Text,edtPop3.Text,StrToInt(edtPort.Text)));
end;

procedure TfrmMain.SaveToLog(idMessage: TidMessage);
begin
  mmoResult.Lines.Add(IdMessage1.UID);
  mmoResult.Lines.Add(IdMessage1.From.Text);
  mmoResult.Lines.Add(IdMessage1.Recipients.EmailAddresses);
  mmoResult.Lines.Add(IdMessage1.CCList.EMailAddresses);
  mmoResult.Lines.Add(IdMessage1.Subject);
  mmoResult.Lines.Add(FormatDateTime('dd mmm yyyy hh:mm:ss', IdMessage1.Date));
  mmoResult.Lines.Add(IdMessage1.ReceiptRecipient.Text);
  mmoResult.Lines.Add(IdMessage1.Organization);
end;

procedure TfrmMain.SetupSSL;
begin
  if chkUseSSL.Checked then  //���� �������� ����� ������������ SSL
  begin
    IdPOP3.IOHandler := SSLHandler; //������������� SSL Handler ��� IdPOP3
    IdPOP3.UseTLS := utUseImplicitTLS;  //������������ ������� TSL

    //������������� ��� SSL
    case cbSSLType.ItemIndex of
      0: SSLHandler.SSLOptions.Method := sslvSSLv2;
      1: SSLHandler.SSLOptions.Method := sslvSSLv23;
      2: SSLHandler.SSLOptions.Method := sslvSSLv3;
      3: SSLHandler.SSLOptions.Method := sslvTLSv1;
    else
      raise Exception.Create('�������� ��� SSL');
    end;
  end
  else
  begin
    IdPOP3.IOHandler := nil; //���� �� ���������� SSL - ������������� ��� �� ���������
    IdPOP3.UseTLS := utNoTLSSupport;
  end;
end;

function TfrmMain.CheckMail(IP:TIdPOP3;User,Pass,Host:string;Port:Integer):String;
var
  NumOfMsgs:Integer; // ���������� �����
  I: Integer;
  J:Integer;
  attfile: TIdMessageParts;
  CountMessages: Integer;
  AttachPath: string;
begin
  try
    IP.Username:=User; // ����� ����������� ����� � ������� (xxx@xxx.xx)
    IP.Password:=Pass; // ������ � ������� ��������� �����
    IP.Host:=Host; // POP3 ������ (pop.mail.ru; pop3.ukr.net)
    IP.Port:=Port; // ����

    SetupSSL;  // ��������� SSL ����������

    IP.Connect; // ������������

    if IP.Connected then // ���� ����������� ������ �������
    begin
       // ���������� � NumOfMsgs ���������� �����
       NumOfMsgs := IP.CheckMessages;
       // ���������� ���������
       Result:='����������� ������ �������!'+#13#10;
       Result:=Result+'� ��� '+IntToStr(NumOfMsgs)+' ���������';


       for I := 1 to NumOfMsgs do
       begin
         if not IP.Retrieve(I, IdMessage1) then
         begin
          //�������� � ��� ��� �� ������� �������� ��������� � ID = I
          Exit;
         end;
//         IP.UIDL(lst1.Items);

         SaveToLog(IdMessage1);

         //������� �����
         AttachPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))+'Attach');
         ForceDirectories(AttachPath);

         for J := 0 to IdMessage1.MessageParts.Count - 1 do
          if IdMessage1.MessageParts[J].PartType = mptAttachment then
          begin
            (IdMessage1.MessageParts[J] as TidAttachmentFile).SaveToFile(AttachPath + IdMessage1.MessageParts[J].FileName);
          end;
       end;


    end
  except // ���� ��������� ������- ���������� ����� ������
    on E:Exception do Result:='������ �����������! '+E.Message;
  end;

  IP.Disconnect; // �����������
end;

end.
