drop Table [dbo].[member]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[member](
	[member_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[lastname] [dbo].[shortstring] NOT NULL,
	[firstname] [dbo].[shortstring] NOT NULL,
	[middleinitial] [dbo].[letter] NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NULL,
	[photograph] [image] NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_no] [dbo].[numeric_id] NULL,
	[prev_balance] [money] NULL,
	[curr_balance] [money] NULL,
	[member_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_issue_dt_default]  DEFAULT (getdate()) FOR [issue_dt]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_expr_dt_default]  DEFAULT (dateadd(year,1,getdate())) FOR [expr_dt]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_prev_balance_default]  DEFAULT (0) FOR [prev_balance]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_curr_balance_default]  DEFAULT (0) FOR [curr_balance]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_status_default]  DEFAULT ('  ') FOR [member_code]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [MSmerge_df_rowguid_705D8395909C4C97ABCFF116E6A70A1D]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_ident] PRIMARY KEY CLUSTERED 
(
	[member_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
