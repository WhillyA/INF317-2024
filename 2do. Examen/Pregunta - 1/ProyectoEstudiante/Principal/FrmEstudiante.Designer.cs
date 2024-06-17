namespace ProyectoEstudiante.Principal
{
	partial class FrmEstudiante
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.DgvEstudiantes = new System.Windows.Forms.DataGridView();
			this.Editar = new System.Windows.Forms.DataGridViewImageColumn();
			this.TxtNombre = new System.Windows.Forms.TextBox();
			this.TxtApellido1 = new System.Windows.Forms.TextBox();
			this.TxtApellido2 = new System.Windows.Forms.TextBox();
			this.LbNombre = new System.Windows.Forms.Label();
			this.LbApellido1 = new System.Windows.Forms.Label();
			this.LbApellido2 = new System.Windows.Forms.Label();
			this.DtpFechaNacimiento = new System.Windows.Forms.DateTimePicker();
			this.ChkEstado = new System.Windows.Forms.CheckBox();
			this.BtnCreate = new System.Windows.Forms.Button();
			this.BtnUpdate = new System.Windows.Forms.Button();
			this.BtnDelete = new System.Windows.Forms.Button();
			this.LblIdEstudiante = new System.Windows.Forms.Label();
			((System.ComponentModel.ISupportInitialize)(this.DgvEstudiantes)).BeginInit();
			this.SuspendLayout();
			// 
			// DgvEstudiantes
			// 
			this.DgvEstudiantes.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
			this.DgvEstudiantes.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			this.DgvEstudiantes.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Editar});
			this.DgvEstudiantes.Location = new System.Drawing.Point(13, 221);
			this.DgvEstudiantes.Name = "DgvEstudiantes";
			this.DgvEstudiantes.RowHeadersWidth = 51;
			this.DgvEstudiantes.RowTemplate.Height = 24;
			this.DgvEstudiantes.Size = new System.Drawing.Size(775, 217);
			this.DgvEstudiantes.TabIndex = 0;
			this.DgvEstudiantes.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.DgvEstudiantes_CellContentClick);
			// 
			// Editar
			// 
			this.Editar.HeaderText = "Editar";
			this.Editar.Image = global::ProyectoEstudiante.Properties.Resources.sada;
			this.Editar.MinimumWidth = 6;
			this.Editar.Name = "Editar";
			// 
			// TxtNombre
			// 
			this.TxtNombre.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F);
			this.TxtNombre.Location = new System.Drawing.Point(27, 69);
			this.TxtNombre.Name = "TxtNombre";
			this.TxtNombre.Size = new System.Drawing.Size(201, 32);
			this.TxtNombre.TabIndex = 1;
			// 
			// TxtApellido1
			// 
			this.TxtApellido1.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F);
			this.TxtApellido1.Location = new System.Drawing.Point(234, 69);
			this.TxtApellido1.Name = "TxtApellido1";
			this.TxtApellido1.Size = new System.Drawing.Size(201, 32);
			this.TxtApellido1.TabIndex = 2;
			// 
			// TxtApellido2
			// 
			this.TxtApellido2.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F);
			this.TxtApellido2.Location = new System.Drawing.Point(441, 69);
			this.TxtApellido2.Name = "TxtApellido2";
			this.TxtApellido2.Size = new System.Drawing.Size(201, 32);
			this.TxtApellido2.TabIndex = 3;
			// 
			// LbNombre
			// 
			this.LbNombre.AutoSize = true;
			this.LbNombre.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.LbNombre.Location = new System.Drawing.Point(30, 42);
			this.LbNombre.Name = "LbNombre";
			this.LbNombre.Size = new System.Drawing.Size(79, 24);
			this.LbNombre.TabIndex = 4;
			this.LbNombre.Text = "Nombre";
			// 
			// LbApellido1
			// 
			this.LbApellido1.AutoSize = true;
			this.LbApellido1.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.LbApellido1.Location = new System.Drawing.Point(234, 42);
			this.LbApellido1.Name = "LbApellido1";
			this.LbApellido1.Size = new System.Drawing.Size(109, 24);
			this.LbApellido1.TabIndex = 5;
			this.LbApellido1.Text = "Ap_Paterno";
			// 
			// LbApellido2
			// 
			this.LbApellido2.AutoSize = true;
			this.LbApellido2.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.LbApellido2.Location = new System.Drawing.Point(441, 42);
			this.LbApellido2.Name = "LbApellido2";
			this.LbApellido2.Size = new System.Drawing.Size(113, 24);
			this.LbApellido2.TabIndex = 6;
			this.LbApellido2.Text = "Ap_Materno";
			// 
			// DtpFechaNacimiento
			// 
			this.DtpFechaNacimiento.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.DtpFechaNacimiento.Location = new System.Drawing.Point(26, 121);
			this.DtpFechaNacimiento.Name = "DtpFechaNacimiento";
			this.DtpFechaNacimiento.Size = new System.Drawing.Size(317, 28);
			this.DtpFechaNacimiento.TabIndex = 7;
			// 
			// ChkEstado
			// 
			this.ChkEstado.AutoSize = true;
			this.ChkEstado.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.ChkEstado.Location = new System.Drawing.Point(385, 121);
			this.ChkEstado.Name = "ChkEstado";
			this.ChkEstado.Size = new System.Drawing.Size(90, 28);
			this.ChkEstado.TabIndex = 8;
			this.ChkEstado.Text = "Estado";
			this.ChkEstado.UseVisualStyleBackColor = true;
			// 
			// BtnCreate
			// 
			this.BtnCreate.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.BtnCreate.Location = new System.Drawing.Point(33, 166);
			this.BtnCreate.Name = "BtnCreate";
			this.BtnCreate.Size = new System.Drawing.Size(162, 34);
			this.BtnCreate.TabIndex = 9;
			this.BtnCreate.Text = "Crear";
			this.BtnCreate.UseVisualStyleBackColor = true;
			this.BtnCreate.Click += new System.EventHandler(this.BtnCreate_Click);
			// 
			// BtnUpdate
			// 
			this.BtnUpdate.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.BtnUpdate.Location = new System.Drawing.Point(273, 166);
			this.BtnUpdate.Name = "BtnUpdate";
			this.BtnUpdate.Size = new System.Drawing.Size(162, 34);
			this.BtnUpdate.TabIndex = 10;
			this.BtnUpdate.Text = "Actualizar";
			this.BtnUpdate.UseVisualStyleBackColor = true;
			this.BtnUpdate.Click += new System.EventHandler(this.BtnUpdate_Click);
			// 
			// BtnDelete
			// 
			this.BtnDelete.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F);
			this.BtnDelete.Location = new System.Drawing.Point(490, 166);
			this.BtnDelete.Name = "BtnDelete";
			this.BtnDelete.Size = new System.Drawing.Size(162, 34);
			this.BtnDelete.TabIndex = 11;
			this.BtnDelete.Text = "Eliminar";
			this.BtnDelete.UseVisualStyleBackColor = true;
			this.BtnDelete.Click += new System.EventHandler(this.BtnDelete_Click);
			// 
			// LblIdEstudiante
			// 
			this.LblIdEstudiante.AutoSize = true;
			this.LblIdEstudiante.Font = new System.Drawing.Font("Microsoft Sans Serif", 13.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.LblIdEstudiante.Location = new System.Drawing.Point(405, 171);
			this.LblIdEstudiante.Name = "LblIdEstudiante";
			this.LblIdEstudiante.Size = new System.Drawing.Size(0, 29);
			this.LblIdEstudiante.TabIndex = 12;
			// 
			// FrmEstudiante
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(800, 450);
			this.Controls.Add(this.LblIdEstudiante);
			this.Controls.Add(this.BtnDelete);
			this.Controls.Add(this.BtnUpdate);
			this.Controls.Add(this.BtnCreate);
			this.Controls.Add(this.ChkEstado);
			this.Controls.Add(this.DtpFechaNacimiento);
			this.Controls.Add(this.LbApellido2);
			this.Controls.Add(this.LbApellido1);
			this.Controls.Add(this.LbNombre);
			this.Controls.Add(this.TxtApellido2);
			this.Controls.Add(this.TxtApellido1);
			this.Controls.Add(this.TxtNombre);
			this.Controls.Add(this.DgvEstudiantes);
			this.Name = "FrmEstudiante";
			this.Text = "FrmEstudiante";
			this.Load += new System.EventHandler(this.FrmEstudiante_Load);
			((System.ComponentModel.ISupportInitialize)(this.DgvEstudiantes)).EndInit();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.DataGridView DgvEstudiantes;
		private System.Windows.Forms.TextBox TxtNombre;
		private System.Windows.Forms.TextBox TxtApellido1;
		private System.Windows.Forms.TextBox TxtApellido2;
		private System.Windows.Forms.Label LbNombre;
		private System.Windows.Forms.Label LbApellido1;
		private System.Windows.Forms.Label LbApellido2;
		private System.Windows.Forms.DateTimePicker DtpFechaNacimiento;
		private System.Windows.Forms.CheckBox ChkEstado;
		private System.Windows.Forms.Button BtnCreate;
		private System.Windows.Forms.Button BtnUpdate;
		private System.Windows.Forms.Button BtnDelete;
		private System.Windows.Forms.DataGridViewImageColumn Editar;
		private System.Windows.Forms.Label LblIdEstudiante;
	}
}