drop Table [dbo].[statement]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[statement](
	[statement_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[statement_dt] [datetime] NOT NULL,
	[due_dt] [datetime] NOT NULL,
	[statement_amt] [money] NOT NULL,
	[statement_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[statement] ADD  CONSTRAINT [statement_status_default]  DEFAULT ('  ') FOR [statement_code]
GO
ALTER TABLE [dbo].[statement] ADD  CONSTRAINT [MSmerge_df_rowguid_4757C7137D9E468F846C3443E8E05012]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[statement] ADD  CONSTRAINT [statement_ident] PRIMARY KEY CLUSTERED 
(
	[statement_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
