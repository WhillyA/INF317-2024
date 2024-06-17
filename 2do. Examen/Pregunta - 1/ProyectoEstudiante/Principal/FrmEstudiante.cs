using Entidades.Estudiantes;
using LogicaNegocio.Estudiantes;
using System;
using System.Windows.Forms;

namespace ProyectoEstudiante.Principal
{
	public partial class FrmEstudiante : Form
	{
		private ClsEstudiante ObjEstudiante = null;
		private readonly ClsEstudianteLn objEstudianteLn = new ClsEstudianteLn();
		public FrmEstudiante()
		{
			InitializeComponent();
			CargarListaEstudiantes();
		}

		private void FrmEstudiante_Load(object sender, EventArgs e)
		{

		}

		private void CargarListaEstudiantes()
		{
			ObjEstudiante = new ClsEstudiante();
			objEstudianteLn.Index(ref ObjEstudiante);
			if (ObjEstudiante.MensajeError == null)
			{
				DgvEstudiantes.DataSource = ObjEstudiante.DtResultado;

			}
			else
			{
				MessageBox.Show(ObjEstudiante.MensajeError, "Mensaje de error", MessageBoxButtons.OK,  MessageBoxIcon.Error);
			}
		}

		private void BtnCreate_Click(object sender, EventArgs e)
		{
			ObjEstudiante = new ClsEstudiante()
			{
				Nombre = TxtNombre.Text,
				Apellido1 = TxtApellido1.Text,
				Apellido2 = TxtApellido2.Text,
				FechaNacimiento = DtpFechaNacimiento.Value,
				Estado = ChkEstado.Checked
			};
			objEstudianteLn.Create(ref ObjEstudiante);
			if (ObjEstudiante.MensajeError == null)
			{
				MessageBox.Show("El ID:  "+ ObjEstudiante.ValorScalar+ ", fue agregado correctamente");
				CargarListaEstudiantes();
			}
			else
			{
				MessageBox.Show(ObjEstudiante.MensajeError, "Mensaje de error", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void BtnUpdate_Click(object sender, EventArgs e)
		{
			ObjEstudiante = new ClsEstudiante()
			{
				IdEstudiante = Convert.ToByte(LblIdEstudiante.Text),
				Nombre = TxtNombre.Text,
				Apellido1 = TxtApellido1.Text,
				Apellido2 = TxtApellido2.Text,
				FechaNacimiento = DtpFechaNacimiento.Value,
				Estado = ChkEstado.Checked
			};

			objEstudianteLn.Update(ref ObjEstudiante);
			if (ObjEstudiante.MensajeError == null)
			{
				MessageBox.Show("El usuario fue actualizado correctamente");
				CargarListaEstudiantes();
			}
			else
			{
				MessageBox.Show(ObjEstudiante.MensajeError, "Mensaje de error", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void DgvEstudiantes_CellContentClick(object sender, DataGridViewCellEventArgs e)
		{
			try
			{
				if (DgvEstudiantes.Columns[e.ColumnIndex].Name == "Editar")
				{
					ObjEstudiante = new ClsEstudiante()
					{
						IdEstudiante = Convert.ToByte(DgvEstudiantes.Rows[e.RowIndex].Cells["IdEstudiante"].Value.ToString())
					};
					LblIdEstudiante.Text = ObjEstudiante.IdEstudiante.ToString();
					objEstudianteLn.Read(ref ObjEstudiante);

					TxtNombre.Text = ObjEstudiante.Nombre;
					TxtApellido1.Text = ObjEstudiante.Apellido1;
					TxtApellido2.Text = ObjEstudiante.Apellido2;
					DtpFechaNacimiento.Value = ObjEstudiante.FechaNacimiento;
					ChkEstado.Checked = ObjEstudiante.Estado;

				}
			}
			catch (Exception ex)
			{

				throw;
			}
		}

		private void BtnDelete_Click(object sender, EventArgs e)
		{
			ObjEstudiante = new ClsEstudiante()
			{
				IdEstudiante = Convert.ToByte(LblIdEstudiante.Text)
			};
			objEstudianteLn.Delete(ref ObjEstudiante);
			CargarListaEstudiantes();
		}
	}
}
