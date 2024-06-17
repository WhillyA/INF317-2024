drop Table [dbo].[payment]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[payment_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[payment_dt] [datetime] NOT NULL,
	[payment_amt] [money] NOT NULL,
	[statement_no] [dbo].[numeric_id] NULL,
	[payment_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[payment] ADD  CONSTRAINT [payment_statement_no_default]  DEFAULT (0) FOR [statement_no]
GO
ALTER TABLE [dbo].[payment] ADD  CONSTRAINT [payment_status_default]  DEFAULT ('  ') FOR [payment_code]
GO
ALTER TABLE [dbo].[payment] ADD  CONSTRAINT [MSmerge_df_rowguid_AC83CE67E310464C985644C7F498A9FC]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

