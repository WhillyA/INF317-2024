drop Table [dbo].[cuentabancaria]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cuentabancaria](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_tipo_cuenta] [int] NULL,
	[saldo] [decimal](10, 2) NULL,
	[fecha_creacion] [date] NULL,
	[id_persona] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[cuentabancaria] ADD  CONSTRAINT [DF__cuentaban__saldo__239E4DCF]  DEFAULT ((0.00)) FOR [saldo]
GO
ALTER TABLE [dbo].[cuentabancaria] ADD  CONSTRAINT [MSmerge_df_rowguid_0C702C89C4344803801BB30D2117EF2C]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[cuentabancaria] ADD  CONSTRAINT [PK__cuentaba__3213E83FA46CA3D3] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
