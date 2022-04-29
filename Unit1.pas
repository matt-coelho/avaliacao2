unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TProva = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Edit2: TEdit;
    FDConnection: TFDConnection;
    nomeProduto: TEdit;
    valorProduto: TEdit;
    Button2: TButton;
    SQLQuery: TFDQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function contaDVD(qDVD:integer):Double;
    function insereProduto(valor:Double; nome:string):Integer;
    function valorVenda(idProduto:Integer; qtd:integer):double;
    function contaProduto(qtd:Integer; idProduto:Integer):double;
    procedure insereProdutoDesconto(idProduto:integer; quantidade:Integer; valor:double);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Prova: TProva;

implementation

{$R *.dfm}

procedure TProva.Button1Click(Sender: TObject);
var produtos:Integer;
begin
  Edit1.Text := FloatToStr(contaDVD(StrToInt(Edit2.Text)));
end;

procedure TProva.Button2Click(Sender: TObject);
var np:string;
    vp:Double;
begin
  np := nomeProduto.Text;
  vp := StrToFloat(valorProduto.Text);

  insereProduto(vp, np);

  nomeProduto.Text := '';
  valorProduto.Text := '';
end;

procedure TProva.insereProdutoDesconto(idProduto:integer; quantidade:Integer; valor:double);
{
Escreva uma função para inserir um registro na tabela ProdutoDesconto, usando
comandos SQL, que recebe como parâmetro o código do produto, a quantidade
inicial da faixa e o valor.
}
begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('SET IDENTITY_INSERT produtodesconto ON');
  SQLQuery.SQL.Add('insert into produtodesconto (quantidade, idproduto, valor) values(:quantidade, :idproduto, :valor)');
  SQLQuery.ParamByName('quantidade').AsInteger := quantidade;
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.SQL.Add('SET IDENTITY_INSERT produtodesconto ON');
  SQLQuery.Prepare;
  SQLQuery.ExecSQL;
  SQLQuery.Close;
end;

function TProva.insereProduto(valor:Double; nome:string):Integer;
{
Escreva uma função para inserir um registro na tabela produto, usando comandos
SQL, que recebe como parâmetro o nome do produto e o valor e retorna o código
que deve ser gerado por esta função.
}
var id:Integer;
begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('insert into produto (nome, valor)values(:nome, :valor)');
  SQLQuery.ParamByName('nome').AsString := nome;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.Prepare;
  SQLQuery.ExecSQL;

  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select idProduto from produto where nome=:nome and valor=:valor');
  SQLQuery.ParamByName('nome').AsString := nome;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.Prepare;
  SQLQuery.Open();
  id := SQLQuery.FieldByName('idProduto').AsInteger;

  SQLQuery.Close;
  insereProduto := id;
end;

function TProva.contaProduto(qtd:Integer; idProduto:Integer):double;
{
QUESTÃO D) Escreva uma função que utilize as funções criadas acima, para inserir
 os registros no banco de dados do problema do EXERCÍCIO 1.
}
var total, valor:Double;
    qtdItens:Integer;
  procedure incrementaTotal(conta:double);
  begin
    total := total + conta;
  end;
begin
  qtdItens := qtd;
  SQLQuery.close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select valor from produto where idproduto=:idproduto');
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.Prepare;
  SQLQuery.Open();
  valor := SQLQuery.FieldByName('valor').AsFloat;
  SQLQuery.Close;
  total := 0; //desconto
  while(qtd >= 10) do
  begin
    incrementaTotal(10 * valor);
    valor := valor - 0.10;
    qtd := qtd - 10;
  end;
  if qtd > 0 then
    incrementaTotal(qtd * valor);
  insereProdutoDesconto(idProduto, qtdItens, total);
  contaProduto := total;
end;

function TProva.contaDVD(qDVD:integer):double;
{
Uma loja vende DVDs por R$ 1,10 a unidade. Acima de 10 unidades, será vendido
cada DVD por R$ 1,00 a unidade adicional e acima de 20 unidades, será vendido
cada unidade adicional a R$ 0,90. Exemplo, vendendo 21 unidades deverá ser
cobrado 10x1.10+10x1.00+1x0.90. Escreva uma função (utilizando Delphi / Pascal)
que receba a quantidade de DVDs a ser vendida e retorne o valor desta venda.
}
var total, valorDVD:Double;
    totalDVDs:Integer;
  procedure incrementaTotal(valor:double);
  begin
    total := total + valor;
  end;
begin
  totalDVDs := qDVD;
  valorDVD := 1.10;
  total := 0;
  while(qDVD >= 10) do
  begin
    incrementaTotal(10 * valorDVD);
    valorDVD := valorDVD - 0.10;
    qDVD := qDVD - 10;
  end;
  if qDVD > 0 then
    incrementaTotal(qDVD * valorDVD);
  insereProdutoDesconto(2, totalDVDs, total);
  contaDVD := total;
end;

function TProva.valorVenda(idProduto:Integer; qtd:integer):double;
var total, valor:double;
{
QUESTÃO E) Escreva uma função que receba como parâmetro o código do produto e a
quantidade a ser vendida, e retorne o valor total da venda. Nesta questão deverá
 ser feito consultas às tabelas criadas no exercício anterior, de forma que
 implemente um algoritmo baseado na questão A) porém com valores armazenados e
 não fixos.  Atenção para o fato de que no exercício A) só temos duas faixas de
 desconto e, neste exercício, as faixas de desconto estão armazenadas na tabela.
}

begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select * from produtodesconto where idProduto=:idproduto');
  SQLQuery.SQL.Add(' and quantidade=:qtd');
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.ParamByName('qtd').AsInteger := qtd;
  SQLQuery.Prepare;
  SQLQuery.Open();
  if(SQLQuery.RecordCount = 1) then
  begin
    total := SQLQuery.FieldByName('valor').AsFloat;
    SQLQuery.Close;
  end else
  begin
    total := contaProduto(qtd,idProduto)
  end;
  valorVenda := total;
end;

end.
