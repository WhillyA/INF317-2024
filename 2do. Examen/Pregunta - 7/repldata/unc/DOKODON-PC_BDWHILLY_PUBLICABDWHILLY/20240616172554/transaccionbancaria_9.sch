drop Table [dbo].[transaccionbancaria]
go
SET ANSI_PADDING ON
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaccionbancaria](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tipo] [varchar](50) NULL,
	[monto] [decimal](10, 2) NULL,
	[fecha] [datetime] NULL,
	[id_cuenta] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[transaccionbancaria] ADD  CONSTRAINT [DF__transacci__fecha__2C3393D0]  DEFAULT (getdate()) FOR [fecha]
GO
ALTER TABLE [dbo].[transaccionbancaria] ADD  CONSTRAINT [MSmerge_df_rowguid_CA7E03098B0947F19255B45148D2525F]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[transaccionbancaria] ADD  CONSTRAINT [PK__transacc__3213E83F35380B57] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
