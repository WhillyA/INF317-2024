drop Table [dbo].[charge]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[charge](
	[charge_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[provider_no] [dbo].[numeric_id] NOT NULL,
	[category_no] [dbo].[numeric_id] NOT NULL,
	[charge_dt] [datetime] NOT NULL,
	[charge_amt] [money] NOT NULL,
	[statement_no] [dbo].[numeric_id] NOT NULL,
	[charge_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [charge_statement_no_default]  DEFAULT (0) FOR [statement_no]
GO
ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [charge_status_default]  DEFAULT ('  ') FOR [charge_code]
GO
ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [MSmerge_df_rowguid_12AAFF979A054F38A849941D4C4BC897]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [ChargePK] PRIMARY KEY CLUSTERED 
(
	[charge_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
