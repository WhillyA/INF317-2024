using System;
using System.Collections.Generic;
using System.Globalization;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
namespace calculadora_p11
{
	public partial class Form1 : Form
	{
		string textoRecibido;
		string resultadoAnterior = "";
		public Form1()
		{
			InitializeComponent();
		}

		private void button6_Click(object sender, EventArgs e)
		{

			string buttonText = ((Button)sender).Text;
			if (resultado.Text == "0" || resultadoAnterior != "")
			{
				resultadoAnterior = "";
				resultado.Text = buttonText;
				textoRecibido = buttonText;
			}
			else
			{
				if (!(resultado.Text == "0" && buttonText == "0"))
				{
					textoRecibido += buttonText;
					resultado.Text += buttonText;
				}
			}
		}

		private void textBox1_TextChanged(object sender, EventArgs e)
		{

		}
		static double calcularDatos(string cadena)
		{
			Stack<double> numeros = new Stack<double>();
			Stack<char> operadores = new Stack<char>();
			int i = 0;

			while (i < cadena.Length)
			{
				if (char.IsDigit(cadena[i]) || cadena[i] == '.')
				{
					string numero = "";
					while (i < cadena.Length && (char.IsDigit(cadena[i]) || cadena[i] == '.'))
					{
						numero += cadena[i];
						i++;
					}
					numeros.Push(double.Parse(numero, CultureInfo.InvariantCulture));
				}
				else
				{
					while (operadores.Count > 0 && Precedencia(operadores.Peek()) >= Precedencia(cadena[i]))
					{
						AplicarOperador(numeros, operadores);
					}
					operadores.Push(cadena[i]);
					i++;
				}
			}

			while (operadores.Count > 0)
			{
				AplicarOperador(numeros, operadores);
			}

			return numeros.Pop();
		}
		static int Precedencia(char operador)
		{
			switch (operador)
			{
				case '+':
				case '-':
					return 1;
				case '*':
				case '/':
					return 2;
				default:
					return 0;
			}
		}

		private void button14_Click(object sender, EventArgs e)
		{
			double operacion = calcularDatos(textoRecibido);
			resultadoAnterior += operacion;
			resultado.Text = operacion.ToString();
			textoRecibido = operacion.ToString();
		}
		static void AplicarOperador(Stack<double> numeros, Stack<char> operadores)
		{
			double b = numeros.Pop();
			double a = numeros.Pop();
			char operador = operadores.Pop();

			switch (operador)
			{
				case '+':
					numeros.Push(a + b);
					break;
				case '-':
					numeros.Push(a - b);
					break;
				case '*':
					numeros.Push(a * b);
					break;
				case '/':
					numeros.Push(a / b);
					break;
			}
		}

		private void button17_Click(object sender, EventArgs e)
		{
			resultado.Text = "";
			textoRecibido = "";
		}


	}
}

/* using System;
using System.Collections.Generic;
using System.Globalization;

namespace calculadora_p11
{
    public partial class Form1 : Form
    {
        string textoRecibido;
        string resultadoAnterior = "";

        public Form1()
        {
            InitializeComponent();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            string buttonText = ((Button)sender).Text;
            if (resultado.Text == "0" || resultadoAnterior != "")
            {
                resultadoAnterior = "";
                resultado.Text = buttonText;
                textoRecibido = buttonText;
            }
            else
            {
                if (!(resultado.Text == "0" && buttonText == "0"))
                {
                    textoRecibido += buttonText;
                    resultado.Text += buttonText;
                }
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        static double calcularDatos(string expresion)
        {
            Stack<double> numeros = new Stack<double>();

            for (int i = expresion.Length - 1; i >= 0; i--)
            {
                if (char.IsDigit(expresion[i]) || expresion[i] == '.')
                {
                    string numero = "";
                    while (i >= 0 && (char.IsDigit(expresion[i]) || expresion[i] == '.'))
                    {
                        numero = expresion[i] + numero;
                        i--;
                    }
                    numeros.Push(double.Parse(numero, CultureInfo.InvariantCulture));
                    i++;
                }
                else if (expresion[i] != ' ')
                {
                    double resultadoOperacion = RealizarOperacion(numeros, expresion[i]);
                    numeros.Push(resultadoOperacion);
                }
            }

            return numeros.Pop();
        }

        static double RealizarOperacion(Stack<double> numeros, char operador)
        {
            double a = numeros.Pop();
            double b = numeros.Pop();

            switch (operador)
            {
                case '+':
                    return a + b;
                case '-':
                    return a - b;
                case '*':
                    return a * b;
                case '/':
                    return a / b;
                default:
                    throw new ArgumentException("Operador no válido");
            }
        }

        private void button14_Click(object sender, EventArgs e)
        {
            double operacion = calcularDatos(textoRecibido);
            resultadoAnterior += operacion;
            resultado.Text = operacion.ToString();
            textoRecibido = operacion.ToString();
        }

        private void button17_Click(object sender, EventArgs e)
        {
            resultado.Text = "";
            textoRecibido = "";
        }
    }
}
 */