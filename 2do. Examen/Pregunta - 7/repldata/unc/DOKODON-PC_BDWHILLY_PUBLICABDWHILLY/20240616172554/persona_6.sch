drop Table [dbo].[persona]
go
SET ANSI_PADDING ON
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[persona](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nombres] [varchar](100) NULL,
	[ap_pat] [varchar](50) NULL,
	[ap_mat] [varchar](50) NULL,
	[fecha_nac] [date] NULL,
	[ci] [int] NULL,
	[direccion] [varchar](255) NULL,
	[password_hash] [varchar](255) NULL,
	[id_rol_usuario] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[persona] ADD  CONSTRAINT [MSmerge_df_rowguid_A5AA2C4B4DFD401190CEBE5E635D166B]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[persona] ADD  CONSTRAINT [PK__persona__3213E83F71B70086] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
