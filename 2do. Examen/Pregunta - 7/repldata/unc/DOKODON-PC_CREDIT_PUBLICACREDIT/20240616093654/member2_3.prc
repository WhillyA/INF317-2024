SET QUOTED_IDENTIFIER ON

go

-- these are subscriber side procs
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


go

-- drop all the procedures first
if object_id('MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA','P') is not NULL
    drop procedure MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA
if object_id('MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA_batch','P') is not NULL
    drop procedure MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA_batch
if object_id('MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA','P') is not NULL
    drop procedure MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA
if object_id('MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA_batch','P') is not NULL
    drop procedure MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA_batch
if object_id('MSmerge_del_sp_CAD585A89B6748A6CEFA968CE17241FA','P') is not NULL
    drop procedure MSmerge_del_sp_CAD585A89B6748A6CEFA968CE17241FA
if object_id('MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA','P') is not NULL
    drop procedure MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA
if object_id('MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA_metadata','P') is not NULL
    drop procedure MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA_metadata
if object_id('MSmerge_cft_sp_CAD585A89B6748A6CEFA968CE17241FA','P') is not NULL
    drop procedure MSmerge_cft_sp_CAD585A89B6748A6CEFA968CE17241FA


go
create procedure dbo.[MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA] (@rowguid uniqueidentifier, 
            @generation bigint, @lineage varbinary(311),  @colv varbinary(1) 
, 
        @p1 [numeric_id]
, 
        @p2 [shortstring]
, 
        @p3 [shortstring]
, 
        @p4 [letter]
, 
        @p5 [shortstring]
, 
        @p6 [shortstring]
, 
        @p7 [statecode]
, 
        @p8 [countrycode]
, 
        @p9 [mailcode]
, 
        @p10 [phonenumber]
, 
        @p11 image
, 
        @p12 datetime
, 
        @p13 datetime
, 
        @p14 [numeric_id]
, 
        @p15 [numeric_id]
, 
        @p16 money
, 
        @p17 money
, 
        @p18 [status_code]
, 
        @p19 uniqueidentifier
,@metadata_type tinyint = NULL, @lineage_old varbinary(311) = NULL, @compatlevel int = 10 
) as
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @tablenick  int
    declare @started_transaction bit
    declare @publication_number smallint
    
    set nocount on

    select @started_transaction = 0
    select @publication_number = 1

    set @errcode= 0
    select @tablenick= 8260001
    
    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end



    declare @resend int

    set @resend = 0 

    if @@trancount = 0 
    begin
        begin transaction
        select @started_transaction = 1
    end
    if @metadata_type = 1 or @metadata_type = 5
    begin
        if @compatlevel < 90 and @lineage_old is not null
            set @lineage_old= {fn LINEAGE_80_TO_90(@lineage_old)}
        -- check meta consistency
        if not exists (select * from dbo.MSmerge_tombstone where tablenick = @tablenick and rowguid = @rowguid and
                        lineage = @lineage_old)
        begin
            set @errcode= 2
            goto Failure
        end
    end
    -- set row meta data
    
        exec @retcode= sys.sp_MSsetrowmetadata 
            @tablenick, @rowguid, @generation, 
            @lineage, @colv, 2, @resend OUTPUT,
            @compatlevel, 1, 'CEFA968C-E172-41FA-B5A5-680EAD11935A'
        if @retcode<>0 or @@ERROR<>0
        begin
            set @errcode= 0
            goto Failure
        end 
    insert into [dbo].[member2] (
[member_no]
, 
        [lastname]
, 
        [firstname]
, 
        [middleinitial]
, 
        [street]
, 
        [city]
, 
        [state_prov]
, 
        [country]
, 
        [mail_code]
, 
        [phone_no]
, 
        [photograph]
, 
        [issue_dt]
, 
        [expr_dt]
, 
        [region_no]
, 
        [corp_no]
, 
        [prev_balance]
, 
        [curr_balance]
, 
        [member_code]
, 
        [rowguid]
) values (
@p1
, 
        @p2
, 
        @p3
, 
        @p4
, 
        @p5
, 
        @p6
, 
        @p7
, 
        @p8
, 
        @p9
, 
        @p10
, 
        @p11
, 
        @p12
, 
        @p13
, 
        @p14
, 
        @p15
, 
        @p16
, 
        @p17
, 
        @p18
, 
        @p19
)
        select @rowcount= @@rowcount, @error= @@error
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end


    -- set row meta data
    if @resend > 0  
        update dbo.MSmerge_contents set generation = 0, partchangegen = 0 
            where rowguid = @rowguid and tablenick = @tablenick 

    if @started_transaction = 1
        commit tran
    

    delete from dbo.MSmerge_metadataaction_request
        where tablenick=@tablenick and rowguid=@rowguid


    return(1)

Failure:
    if @started_transaction = 1
        rollback tran

    


    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[member2] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 8260001 and
                (

                        (t.[member_no]=@p1)

                        )
            end

    return(@errcode)
    

go
Create procedure dbo.[MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA] (@rowguid uniqueidentifier, @setbm varbinary(125) = NULL,
        @metadata_type tinyint, @lineage_old varbinary(311), @generation bigint,
        @lineage_new varbinary(311), @colv varbinary(1) 
,
        @p1 [numeric_id] = NULL 
,
        @p2 [shortstring] = NULL 
,
        @p3 [shortstring] = NULL 
,
        @p4 [letter] = NULL 
,
        @p5 [shortstring] = NULL 
,
        @p6 [shortstring] = NULL 
,
        @p7 [statecode] = NULL 
,
        @p8 [countrycode] = NULL 
,
        @p9 [mailcode] = NULL 
,
        @p10 [phonenumber] = NULL 
,
        @p11 image = NULL 
,
        @p12 datetime = NULL 
,
        @p13 datetime = NULL 
,
        @p14 [numeric_id] = NULL 
,
        @p15 [numeric_id] = NULL 
,
        @p16 money = NULL 
,
        @p17 money = NULL 
,
        @p18 [status_code] = NULL 
,
        @p19 uniqueidentifier = NULL 
, @compatlevel int = 10 
)
as
    declare @match int 

    declare @fset int
    declare @errcode int
    declare @retcode smallint
    declare @rowcount int
    declare @error int
    declare @hasperm bit
    declare @tablenick int
    declare @started_transaction bit
    declare @indexing_column_updated bit
    declare @publication_number smallint

    set nocount on

    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    select @started_transaction = 0
    select @publication_number = 1
    select @tablenick = 8260001

    if is_member('db_owner') = 1
        select @hasperm = 1
    else
        select @hasperm = 0

    select @indexing_column_updated = 0

    declare @l1 [numeric_id]

    declare @iscol1set bit

    declare @l2 [shortstring]

    declare @iscol2set bit

    declare @l3 [shortstring]

    declare @iscol3set bit

    declare @l4 [letter]

    declare @iscol4set bit

    declare @l14 [numeric_id]

    declare @iscol14set bit

    declare @l15 [numeric_id]

    declare @iscol15set bit

    if @@trancount = 0
    begin
        begin transaction sub
        select @started_transaction = 1
    end


    select 

        @l1 = [member_no]
, 
        @l2 = [lastname]
, 
        @l3 = [firstname]
, 
        @l4 = [middleinitial]
, 
        @l14 = [region_no]
, 
        @l15 = [corp_no]
        from [dbo].[member2] where rowguidcol = @rowguid
    set @match = NULL

       
    declare @firstUpdStmtCol bit
    declare @nUpdateCols int
    declare @updatestmt nvarchar(4000) 
    
    select @firstUpdStmtCol = 1
    select @nUpdateCols = 0
    select @updatestmt = 'update ' + '[dbo].[member2]' + ' set '
            

    if @p11 is not null
        set @fset = 1
    else    
        exec @fset = sys.sp_MStestbit @setbm, 11
    if @fset <> 0
    begin

        if @match is NULL
        begin
            if @metadata_type = 3
            begin
                update [dbo].[member2] set [photograph] = @p11 
                from [dbo].[member2] t 
                where t.[rowguid] = @rowguid and
                   not exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                where c.rowguid = @rowguid and 
                                      c.tablenick = 8260001)
            end
            else if @metadata_type = 2
            begin
                update [dbo].[member2] set [photograph] = @p11 
                from [dbo].[member2] t 
                where t.[rowguid] = @rowguid and
                      exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                where c.rowguid = @rowguid and 
                                      c.tablenick = 8260001 and
                                      c.lineage = @lineage_old)
            end
            else
            begin
                set @errcode=2
                goto Failure
            end
        end
        else
        begin
            update [dbo].[member2] set [photograph] = @p11 
                where rowguidcol = @rowguid
        end
        select @rowcount= @@rowcount, @error= @@error
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end
        select @match = 1
    end 

    if @p1 = @l1
        set @fset = 0
    else if ( @l1 is null and @p1 is null) 
        set @fset = 0
    else if @p1 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 1
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol1set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[member_no] = @p1'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol1set = 0
    end

    if convert(varbinary(15), @p2)
            = convert(varbinary(15), @l2)
        set @fset = 0
    else if ( @l2 is null and @p2 is null) 
        set @fset = 0
    else if @p2 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 2
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol2set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[lastname] = @p2'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol2set = 0
    end

    if convert(varbinary(15), @p3)
            = convert(varbinary(15), @l3)
        set @fset = 0
    else if ( @l3 is null and @p3 is null) 
        set @fset = 0
    else if @p3 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 3
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol3set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[firstname] = @p3'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol3set = 0
    end

    if convert(varbinary(1), @p4)
            = convert(varbinary(1), @l4)
        set @fset = 0
    else if ( @l4 is null and @p4 is null) 
        set @fset = 0
    else if @p4 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 4
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol4set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[middleinitial] = @p4'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol4set = 0
    end

    if @p14 = @l14
        set @fset = 0
    else if ( @l14 is null and @p14 is null) 
        set @fset = 0
    else if @p14 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 14
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol14set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[region_no] = @p14'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol14set = 0
    end

    if @p15 = @l15
        set @fset = 0
    else if ( @l15 is null and @p15 is null) 
        set @fset = 0
    else if @p15 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 15
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol15set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[corp_no] = @p15'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol15set = 0
    end

    if @indexing_column_updated = 1
    begin
        if @hasperm = 0
        begin
            update [dbo].[member2] set 

                [member_no] = case @iscol1set when 1 then @p1 else t.[member_no] end
,
                [lastname] = case @iscol2set when 1 then @p2 else t.[lastname] end
,
                [firstname] = case @iscol3set when 1 then @p3 else t.[firstname] end
,
                [middleinitial] = case @iscol4set when 1 then @p4 else t.[middleinitial] end
,
                [region_no] = case @iscol14set when 1 then @p14 else t.[region_no] end
,
                [corp_no] = case @iscol15set when 1 then @p15 else t.[corp_no] end
 
             from [dbo].[member2] t 
                left outer join dbo.MSmerge_contents c with (rowlock)
                    on c.rowguid = t.[rowguid] and 
                       c.tablenick = 8260001 and
                       t.[rowguid] = @rowguid
             where t.[rowguid] = @rowguid and
             ((@match is not NULL and @match = 1) or 
              ((@metadata_type = 3 and c.rowguid is NULL) or
               (@metadata_type = 2 and c.rowguid is not NULL and c.lineage = @lineage_old)))

            select @rowcount= @@rowcount, @error= @@error

        end
        else -- we can do sp_executesql since the current user has permissions to update the table
        begin 
            if @match is NULL
            begin
                if @metadata_type = 3
                begin
                    select @updatestmt = @updatestmt + '
                       from [dbo].[member2] t 
                       where t.[rowguid] = @rowguid and
                             not exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                         where c.rowguid = @rowguid and 
                                               c.tablenick = 8260001)'
                end
                else if @metadata_type = 2
                begin
                    select @updatestmt = @updatestmt + '
                       from [dbo].[member2] t 
                       where t.[rowguid] = @rowguid and
                             exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                     where c.rowguid = @rowguid and 
                                           c.tablenick = 8260001 and
                                           c.lineage = @lineage_old)'
                end
            end
            else
            begin
                select @updatestmt = @updatestmt + '
                    where rowguidcol = @rowguid '
            end
            select @updatestmt = @updatestmt + '
                select @rowcount = @@rowcount, @error = @@error'
            exec sys.sp_executesql @stmt = @updatestmt, @parameters = N'

                    @p1 [numeric_id]
,

                    @p2 [shortstring]
,

                    @p3 [shortstring]
,

                    @p4 [letter]
,

                    @p14 [numeric_id]
,

                    @p15 [numeric_id]
, @rowguid uniqueidentifier = ''00000000-0000-0000-0000-000000000000'', @lineage_old varbinary(311), @rowcount int output, @error int output',

                    @p1 = @p1
,

                    @p2 = @p2
,

                    @p3 = @p3
,

                    @p4 = @p4
,

                    @p14 = @p14
,

                    @p15 = @p15

                    , @rowguid = @rowguid, @lineage_old = @lineage_old, @rowcount = @rowcount OUTPUT, @error = @error OUTPUT 
        end  -- end if @hasperm
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end    
        select @match = 1    
    end -- end if @indexing_column_updated 

    if @match is NULL
    begin
        update [dbo].[member2] set 

            [street] = case when @p5 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 5) <> 0 then @p5 else t.[street] end) else @p5 end 
,

            [city] = case when @p6 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 6) <> 0 then @p6 else t.[city] end) else @p6 end 
,

            [state_prov] = case when @p7 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 7) <> 0 then @p7 else t.[state_prov] end) else @p7 end 
,

            [country] = case when @p8 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 8) <> 0 then @p8 else t.[country] end) else @p8 end 
,

            [mail_code] = case when @p9 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 9) <> 0 then @p9 else t.[mail_code] end) else @p9 end 
,

            [phone_no] = case when @p10 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 10) <> 0 then @p10 else t.[phone_no] end) else @p10 end 
,

            [issue_dt] = case when @p12 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 12) <> 0 then @p12 else t.[issue_dt] end) else @p12 end 
,

            [expr_dt] = case when @p13 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 13) <> 0 then @p13 else t.[expr_dt] end) else @p13 end 
,

            [prev_balance] = case when @p16 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 16) <> 0 then @p16 else t.[prev_balance] end) else @p16 end 
,

            [curr_balance] = case when @p17 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 17) <> 0 then @p17 else t.[curr_balance] end) else @p17 end 
,

            [member_code] = case when @p18 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 18) <> 0 then @p18 else t.[member_code] end) else @p18 end 
 
         from [dbo].[member2] t 
            left outer join dbo.MSmerge_contents c with (rowlock)
                on c.rowguid = t.[rowguid] and 
                   c.tablenick = 8260001 and
                   t.[rowguid] = @rowguid
         where t.[rowguid] = @rowguid and
         ((@match is not NULL and @match = 1) or 
          ((@metadata_type = 3 and c.rowguid is NULL) or
           (@metadata_type = 2 and c.rowguid is not NULL and c.lineage = @lineage_old)))

        select @rowcount= @@rowcount, @error= @@error
    end
    else
    begin
        update [dbo].[member2] set 

            [street] = case when @p5 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 5) <> 0 then @p5 else t.[street] end) else @p5 end 
,

            [city] = case when @p6 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 6) <> 0 then @p6 else t.[city] end) else @p6 end 
,

            [state_prov] = case when @p7 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 7) <> 0 then @p7 else t.[state_prov] end) else @p7 end 
,

            [country] = case when @p8 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 8) <> 0 then @p8 else t.[country] end) else @p8 end 
,

            [mail_code] = case when @p9 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 9) <> 0 then @p9 else t.[mail_code] end) else @p9 end 
,

            [phone_no] = case when @p10 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 10) <> 0 then @p10 else t.[phone_no] end) else @p10 end 
,

            [issue_dt] = case when @p12 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 12) <> 0 then @p12 else t.[issue_dt] end) else @p12 end 
,

            [expr_dt] = case when @p13 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 13) <> 0 then @p13 else t.[expr_dt] end) else @p13 end 
,

            [prev_balance] = case when @p16 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 16) <> 0 then @p16 else t.[prev_balance] end) else @p16 end 
,

            [curr_balance] = case when @p17 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 17) <> 0 then @p17 else t.[curr_balance] end) else @p17 end 
,

            [member_code] = case when @p18 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 18) <> 0 then @p18 else t.[member_code] end) else @p18 end 
 
         from [dbo].[member2] t 
             where t.[rowguid] = @rowguid

        select @rowcount= @@rowcount, @error= @@error
    end

    if (@rowcount <> 1) or (@error <> 0)
    begin
        set @errcode= 3
        goto Failure
    end

    select @match = 1
 
    exec @retcode= sys.sp_MSsetrowmetadata 
        @tablenick, @rowguid, @generation, 
        @lineage_new, @colv, 2, NULL, 
        @compatlevel, 0, 'CEFA968C-E172-41FA-B5A5-680EAD11935A'
    if @retcode<>0 or @@ERROR<>0
    begin
        set @errcode= 3
        goto Failure
    end 

delete from dbo.MSmerge_metadataaction_request
    where tablenick=@tablenick and rowguid=@rowguid

    if @started_transaction = 1
        commit transaction


    return(1)

Failure:
    --rollback transaction sub
    --commit transaction
    if @started_transaction = 1    
        rollback transaction




    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[member2] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 8260001 and
                (

                        (t.[member_no]=@p1)

                        )
            end

    return @errcode

go

create procedure dbo.[MSmerge_del_sp_CAD585A89B6748A6CEFA968CE17241FA]
(
    @rowstobedeleted int, 
    @partition_id int = NULL 
,
    @rowguid1 uniqueidentifier = NULL,
    @metadata_type1 tinyint = NULL,
    @generation1 bigint = NULL,
    @lineage_old1 varbinary(311) = NULL,
    @lineage_new1 varbinary(311) = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @metadata_type2 tinyint = NULL,
    @generation2 bigint = NULL,
    @lineage_old2 varbinary(311) = NULL,
    @lineage_new2 varbinary(311) = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @metadata_type3 tinyint = NULL,
    @generation3 bigint = NULL,
    @lineage_old3 varbinary(311) = NULL,
    @lineage_new3 varbinary(311) = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @metadata_type4 tinyint = NULL,
    @generation4 bigint = NULL,
    @lineage_old4 varbinary(311) = NULL,
    @lineage_new4 varbinary(311) = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @metadata_type5 tinyint = NULL,
    @generation5 bigint = NULL,
    @lineage_old5 varbinary(311) = NULL,
    @lineage_new5 varbinary(311) = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @metadata_type6 tinyint = NULL,
    @generation6 bigint = NULL,
    @lineage_old6 varbinary(311) = NULL,
    @lineage_new6 varbinary(311) = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @metadata_type7 tinyint = NULL,
    @generation7 bigint = NULL,
    @lineage_old7 varbinary(311) = NULL,
    @lineage_new7 varbinary(311) = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @metadata_type8 tinyint = NULL,
    @generation8 bigint = NULL,
    @lineage_old8 varbinary(311) = NULL,
    @lineage_new8 varbinary(311) = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @metadata_type9 tinyint = NULL,
    @generation9 bigint = NULL,
    @lineage_old9 varbinary(311) = NULL,
    @lineage_new9 varbinary(311) = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @metadata_type10 tinyint = NULL,
    @generation10 bigint = NULL,
    @lineage_old10 varbinary(311) = NULL,
    @lineage_new10 varbinary(311) = NULL
,
    @rowguid11 uniqueidentifier = NULL,
    @metadata_type11 tinyint = NULL,
    @generation11 bigint = NULL,
    @lineage_old11 varbinary(311) = NULL,
    @lineage_new11 varbinary(311) = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @metadata_type12 tinyint = NULL,
    @generation12 bigint = NULL,
    @lineage_old12 varbinary(311) = NULL,
    @lineage_new12 varbinary(311) = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @metadata_type13 tinyint = NULL,
    @generation13 bigint = NULL,
    @lineage_old13 varbinary(311) = NULL,
    @lineage_new13 varbinary(311) = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @metadata_type14 tinyint = NULL,
    @generation14 bigint = NULL,
    @lineage_old14 varbinary(311) = NULL,
    @lineage_new14 varbinary(311) = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @metadata_type15 tinyint = NULL,
    @generation15 bigint = NULL,
    @lineage_old15 varbinary(311) = NULL,
    @lineage_new15 varbinary(311) = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @metadata_type16 tinyint = NULL,
    @generation16 bigint = NULL,
    @lineage_old16 varbinary(311) = NULL,
    @lineage_new16 varbinary(311) = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @metadata_type17 tinyint = NULL,
    @generation17 bigint = NULL,
    @lineage_old17 varbinary(311) = NULL,
    @lineage_new17 varbinary(311) = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @metadata_type18 tinyint = NULL,
    @generation18 bigint = NULL,
    @lineage_old18 varbinary(311) = NULL,
    @lineage_new18 varbinary(311) = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @metadata_type19 tinyint = NULL,
    @generation19 bigint = NULL,
    @lineage_old19 varbinary(311) = NULL,
    @lineage_new19 varbinary(311) = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @metadata_type20 tinyint = NULL,
    @generation20 bigint = NULL,
    @lineage_old20 varbinary(311) = NULL,
    @lineage_new20 varbinary(311) = NULL
,
    @rowguid21 uniqueidentifier = NULL,
    @metadata_type21 tinyint = NULL,
    @generation21 bigint = NULL,
    @lineage_old21 varbinary(311) = NULL,
    @lineage_new21 varbinary(311) = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @metadata_type22 tinyint = NULL,
    @generation22 bigint = NULL,
    @lineage_old22 varbinary(311) = NULL,
    @lineage_new22 varbinary(311) = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @metadata_type23 tinyint = NULL,
    @generation23 bigint = NULL,
    @lineage_old23 varbinary(311) = NULL,
    @lineage_new23 varbinary(311) = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @metadata_type24 tinyint = NULL,
    @generation24 bigint = NULL,
    @lineage_old24 varbinary(311) = NULL,
    @lineage_new24 varbinary(311) = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @metadata_type25 tinyint = NULL,
    @generation25 bigint = NULL,
    @lineage_old25 varbinary(311) = NULL,
    @lineage_new25 varbinary(311) = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @metadata_type26 tinyint = NULL,
    @generation26 bigint = NULL,
    @lineage_old26 varbinary(311) = NULL,
    @lineage_new26 varbinary(311) = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @metadata_type27 tinyint = NULL,
    @generation27 bigint = NULL,
    @lineage_old27 varbinary(311) = NULL,
    @lineage_new27 varbinary(311) = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @metadata_type28 tinyint = NULL,
    @generation28 bigint = NULL,
    @lineage_old28 varbinary(311) = NULL,
    @lineage_new28 varbinary(311) = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @metadata_type29 tinyint = NULL,
    @generation29 bigint = NULL,
    @lineage_old29 varbinary(311) = NULL,
    @lineage_new29 varbinary(311) = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @metadata_type30 tinyint = NULL,
    @generation30 bigint = NULL,
    @lineage_old30 varbinary(311) = NULL,
    @lineage_new30 varbinary(311) = NULL
,
    @rowguid31 uniqueidentifier = NULL,
    @metadata_type31 tinyint = NULL,
    @generation31 bigint = NULL,
    @lineage_old31 varbinary(311) = NULL,
    @lineage_new31 varbinary(311) = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @metadata_type32 tinyint = NULL,
    @generation32 bigint = NULL,
    @lineage_old32 varbinary(311) = NULL,
    @lineage_new32 varbinary(311) = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @metadata_type33 tinyint = NULL,
    @generation33 bigint = NULL,
    @lineage_old33 varbinary(311) = NULL,
    @lineage_new33 varbinary(311) = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @metadata_type34 tinyint = NULL,
    @generation34 bigint = NULL,
    @lineage_old34 varbinary(311) = NULL,
    @lineage_new34 varbinary(311) = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @metadata_type35 tinyint = NULL,
    @generation35 bigint = NULL,
    @lineage_old35 varbinary(311) = NULL,
    @lineage_new35 varbinary(311) = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @metadata_type36 tinyint = NULL,
    @generation36 bigint = NULL,
    @lineage_old36 varbinary(311) = NULL,
    @lineage_new36 varbinary(311) = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @metadata_type37 tinyint = NULL,
    @generation37 bigint = NULL,
    @lineage_old37 varbinary(311) = NULL,
    @lineage_new37 varbinary(311) = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @metadata_type38 tinyint = NULL,
    @generation38 bigint = NULL,
    @lineage_old38 varbinary(311) = NULL,
    @lineage_new38 varbinary(311) = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @metadata_type39 tinyint = NULL,
    @generation39 bigint = NULL,
    @lineage_old39 varbinary(311) = NULL,
    @lineage_new39 varbinary(311) = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @metadata_type40 tinyint = NULL,
    @generation40 bigint = NULL,
    @lineage_old40 varbinary(311) = NULL,
    @lineage_new40 varbinary(311) = NULL
,
    @rowguid41 uniqueidentifier = NULL,
    @metadata_type41 tinyint = NULL,
    @generation41 bigint = NULL,
    @lineage_old41 varbinary(311) = NULL,
    @lineage_new41 varbinary(311) = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @metadata_type42 tinyint = NULL,
    @generation42 bigint = NULL,
    @lineage_old42 varbinary(311) = NULL,
    @lineage_new42 varbinary(311) = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @metadata_type43 tinyint = NULL,
    @generation43 bigint = NULL,
    @lineage_old43 varbinary(311) = NULL,
    @lineage_new43 varbinary(311) = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @metadata_type44 tinyint = NULL,
    @generation44 bigint = NULL,
    @lineage_old44 varbinary(311) = NULL,
    @lineage_new44 varbinary(311) = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @metadata_type45 tinyint = NULL,
    @generation45 bigint = NULL,
    @lineage_old45 varbinary(311) = NULL,
    @lineage_new45 varbinary(311) = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @metadata_type46 tinyint = NULL,
    @generation46 bigint = NULL,
    @lineage_old46 varbinary(311) = NULL,
    @lineage_new46 varbinary(311) = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @metadata_type47 tinyint = NULL,
    @generation47 bigint = NULL,
    @lineage_old47 varbinary(311) = NULL,
    @lineage_new47 varbinary(311) = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @metadata_type48 tinyint = NULL,
    @generation48 bigint = NULL,
    @lineage_old48 varbinary(311) = NULL,
    @lineage_new48 varbinary(311) = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @metadata_type49 tinyint = NULL,
    @generation49 bigint = NULL,
    @lineage_old49 varbinary(311) = NULL,
    @lineage_new49 varbinary(311) = NULL,
    @rowguid50 uniqueidentifier = NULL,
    @metadata_type50 tinyint = NULL,
    @generation50 bigint = NULL,
    @lineage_old50 varbinary(311) = NULL,
    @lineage_new50 varbinary(311) = NULL
,
    @rowguid51 uniqueidentifier = NULL,
    @metadata_type51 tinyint = NULL,
    @generation51 bigint = NULL,
    @lineage_old51 varbinary(311) = NULL,
    @lineage_new51 varbinary(311) = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @metadata_type52 tinyint = NULL,
    @generation52 bigint = NULL,
    @lineage_old52 varbinary(311) = NULL,
    @lineage_new52 varbinary(311) = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @metadata_type53 tinyint = NULL,
    @generation53 bigint = NULL,
    @lineage_old53 varbinary(311) = NULL,
    @lineage_new53 varbinary(311) = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @metadata_type54 tinyint = NULL,
    @generation54 bigint = NULL,
    @lineage_old54 varbinary(311) = NULL,
    @lineage_new54 varbinary(311) = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @metadata_type55 tinyint = NULL,
    @generation55 bigint = NULL,
    @lineage_old55 varbinary(311) = NULL,
    @lineage_new55 varbinary(311) = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @metadata_type56 tinyint = NULL,
    @generation56 bigint = NULL,
    @lineage_old56 varbinary(311) = NULL,
    @lineage_new56 varbinary(311) = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @metadata_type57 tinyint = NULL,
    @generation57 bigint = NULL,
    @lineage_old57 varbinary(311) = NULL,
    @lineage_new57 varbinary(311) = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @metadata_type58 tinyint = NULL,
    @generation58 bigint = NULL,
    @lineage_old58 varbinary(311) = NULL,
    @lineage_new58 varbinary(311) = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @metadata_type59 tinyint = NULL,
    @generation59 bigint = NULL,
    @lineage_old59 varbinary(311) = NULL,
    @lineage_new59 varbinary(311) = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @metadata_type60 tinyint = NULL,
    @generation60 bigint = NULL,
    @lineage_old60 varbinary(311) = NULL,
    @lineage_new60 varbinary(311) = NULL
,
    @rowguid61 uniqueidentifier = NULL,
    @metadata_type61 tinyint = NULL,
    @generation61 bigint = NULL,
    @lineage_old61 varbinary(311) = NULL,
    @lineage_new61 varbinary(311) = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @metadata_type62 tinyint = NULL,
    @generation62 bigint = NULL,
    @lineage_old62 varbinary(311) = NULL,
    @lineage_new62 varbinary(311) = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @metadata_type63 tinyint = NULL,
    @generation63 bigint = NULL,
    @lineage_old63 varbinary(311) = NULL,
    @lineage_new63 varbinary(311) = NULL,
    @rowguid64 uniqueidentifier = NULL,
    @metadata_type64 tinyint = NULL,
    @generation64 bigint = NULL,
    @lineage_old64 varbinary(311) = NULL,
    @lineage_new64 varbinary(311) = NULL,
    @rowguid65 uniqueidentifier = NULL,
    @metadata_type65 tinyint = NULL,
    @generation65 bigint = NULL,
    @lineage_old65 varbinary(311) = NULL,
    @lineage_new65 varbinary(311) = NULL,
    @rowguid66 uniqueidentifier = NULL,
    @metadata_type66 tinyint = NULL,
    @generation66 bigint = NULL,
    @lineage_old66 varbinary(311) = NULL,
    @lineage_new66 varbinary(311) = NULL,
    @rowguid67 uniqueidentifier = NULL,
    @metadata_type67 tinyint = NULL,
    @generation67 bigint = NULL,
    @lineage_old67 varbinary(311) = NULL,
    @lineage_new67 varbinary(311) = NULL,
    @rowguid68 uniqueidentifier = NULL,
    @metadata_type68 tinyint = NULL,
    @generation68 bigint = NULL,
    @lineage_old68 varbinary(311) = NULL,
    @lineage_new68 varbinary(311) = NULL,
    @rowguid69 uniqueidentifier = NULL,
    @metadata_type69 tinyint = NULL,
    @generation69 bigint = NULL,
    @lineage_old69 varbinary(311) = NULL,
    @lineage_new69 varbinary(311) = NULL,
    @rowguid70 uniqueidentifier = NULL,
    @metadata_type70 tinyint = NULL,
    @generation70 bigint = NULL,
    @lineage_old70 varbinary(311) = NULL,
    @lineage_new70 varbinary(311) = NULL
,
    @rowguid71 uniqueidentifier = NULL,
    @metadata_type71 tinyint = NULL,
    @generation71 bigint = NULL,
    @lineage_old71 varbinary(311) = NULL,
    @lineage_new71 varbinary(311) = NULL,
    @rowguid72 uniqueidentifier = NULL,
    @metadata_type72 tinyint = NULL,
    @generation72 bigint = NULL,
    @lineage_old72 varbinary(311) = NULL,
    @lineage_new72 varbinary(311) = NULL,
    @rowguid73 uniqueidentifier = NULL,
    @metadata_type73 tinyint = NULL,
    @generation73 bigint = NULL,
    @lineage_old73 varbinary(311) = NULL,
    @lineage_new73 varbinary(311) = NULL,
    @rowguid74 uniqueidentifier = NULL,
    @metadata_type74 tinyint = NULL,
    @generation74 bigint = NULL,
    @lineage_old74 varbinary(311) = NULL,
    @lineage_new74 varbinary(311) = NULL,
    @rowguid75 uniqueidentifier = NULL,
    @metadata_type75 tinyint = NULL,
    @generation75 bigint = NULL,
    @lineage_old75 varbinary(311) = NULL,
    @lineage_new75 varbinary(311) = NULL,
    @rowguid76 uniqueidentifier = NULL,
    @metadata_type76 tinyint = NULL,
    @generation76 bigint = NULL,
    @lineage_old76 varbinary(311) = NULL,
    @lineage_new76 varbinary(311) = NULL,
    @rowguid77 uniqueidentifier = NULL,
    @metadata_type77 tinyint = NULL,
    @generation77 bigint = NULL,
    @lineage_old77 varbinary(311) = NULL,
    @lineage_new77 varbinary(311) = NULL,
    @rowguid78 uniqueidentifier = NULL,
    @metadata_type78 tinyint = NULL,
    @generation78 bigint = NULL,
    @lineage_old78 varbinary(311) = NULL,
    @lineage_new78 varbinary(311) = NULL,
    @rowguid79 uniqueidentifier = NULL,
    @metadata_type79 tinyint = NULL,
    @generation79 bigint = NULL,
    @lineage_old79 varbinary(311) = NULL,
    @lineage_new79 varbinary(311) = NULL,
    @rowguid80 uniqueidentifier = NULL,
    @metadata_type80 tinyint = NULL,
    @generation80 bigint = NULL,
    @lineage_old80 varbinary(311) = NULL,
    @lineage_new80 varbinary(311) = NULL
,
    @rowguid81 uniqueidentifier = NULL,
    @metadata_type81 tinyint = NULL,
    @generation81 bigint = NULL,
    @lineage_old81 varbinary(311) = NULL,
    @lineage_new81 varbinary(311) = NULL,
    @rowguid82 uniqueidentifier = NULL,
    @metadata_type82 tinyint = NULL,
    @generation82 bigint = NULL,
    @lineage_old82 varbinary(311) = NULL,
    @lineage_new82 varbinary(311) = NULL,
    @rowguid83 uniqueidentifier = NULL,
    @metadata_type83 tinyint = NULL,
    @generation83 bigint = NULL,
    @lineage_old83 varbinary(311) = NULL,
    @lineage_new83 varbinary(311) = NULL,
    @rowguid84 uniqueidentifier = NULL,
    @metadata_type84 tinyint = NULL,
    @generation84 bigint = NULL,
    @lineage_old84 varbinary(311) = NULL,
    @lineage_new84 varbinary(311) = NULL,
    @rowguid85 uniqueidentifier = NULL,
    @metadata_type85 tinyint = NULL,
    @generation85 bigint = NULL,
    @lineage_old85 varbinary(311) = NULL,
    @lineage_new85 varbinary(311) = NULL,
    @rowguid86 uniqueidentifier = NULL,
    @metadata_type86 tinyint = NULL,
    @generation86 bigint = NULL,
    @lineage_old86 varbinary(311) = NULL,
    @lineage_new86 varbinary(311) = NULL,
    @rowguid87 uniqueidentifier = NULL,
    @metadata_type87 tinyint = NULL,
    @generation87 bigint = NULL,
    @lineage_old87 varbinary(311) = NULL,
    @lineage_new87 varbinary(311) = NULL,
    @rowguid88 uniqueidentifier = NULL,
    @metadata_type88 tinyint = NULL,
    @generation88 bigint = NULL,
    @lineage_old88 varbinary(311) = NULL,
    @lineage_new88 varbinary(311) = NULL,
    @rowguid89 uniqueidentifier = NULL,
    @metadata_type89 tinyint = NULL,
    @generation89 bigint = NULL,
    @lineage_old89 varbinary(311) = NULL,
    @lineage_new89 varbinary(311) = NULL,
    @rowguid90 uniqueidentifier = NULL,
    @metadata_type90 tinyint = NULL,
    @generation90 bigint = NULL,
    @lineage_old90 varbinary(311) = NULL,
    @lineage_new90 varbinary(311) = NULL
,
    @rowguid91 uniqueidentifier = NULL,
    @metadata_type91 tinyint = NULL,
    @generation91 bigint = NULL,
    @lineage_old91 varbinary(311) = NULL,
    @lineage_new91 varbinary(311) = NULL,
    @rowguid92 uniqueidentifier = NULL,
    @metadata_type92 tinyint = NULL,
    @generation92 bigint = NULL,
    @lineage_old92 varbinary(311) = NULL,
    @lineage_new92 varbinary(311) = NULL,
    @rowguid93 uniqueidentifier = NULL,
    @metadata_type93 tinyint = NULL,
    @generation93 bigint = NULL,
    @lineage_old93 varbinary(311) = NULL,
    @lineage_new93 varbinary(311) = NULL,
    @rowguid94 uniqueidentifier = NULL,
    @metadata_type94 tinyint = NULL,
    @generation94 bigint = NULL,
    @lineage_old94 varbinary(311) = NULL,
    @lineage_new94 varbinary(311) = NULL,
    @rowguid95 uniqueidentifier = NULL,
    @metadata_type95 tinyint = NULL,
    @generation95 bigint = NULL,
    @lineage_old95 varbinary(311) = NULL,
    @lineage_new95 varbinary(311) = NULL,
    @rowguid96 uniqueidentifier = NULL,
    @metadata_type96 tinyint = NULL,
    @generation96 bigint = NULL,
    @lineage_old96 varbinary(311) = NULL,
    @lineage_new96 varbinary(311) = NULL,
    @rowguid97 uniqueidentifier = NULL,
    @metadata_type97 tinyint = NULL,
    @generation97 bigint = NULL,
    @lineage_old97 varbinary(311) = NULL,
    @lineage_new97 varbinary(311) = NULL,
    @rowguid98 uniqueidentifier = NULL,
    @metadata_type98 tinyint = NULL,
    @generation98 bigint = NULL,
    @lineage_old98 varbinary(311) = NULL,
    @lineage_new98 varbinary(311) = NULL,
    @rowguid99 uniqueidentifier = NULL,
    @metadata_type99 tinyint = NULL,
    @generation99 bigint = NULL,
    @lineage_old99 varbinary(311) = NULL,
    @lineage_new99 varbinary(311) = NULL,
    @rowguid100 uniqueidentifier = NULL,
    @metadata_type100 tinyint = NULL,
    @generation100 bigint = NULL,
    @lineage_old100 varbinary(311) = NULL,
    @lineage_new100 varbinary(311) = NULL

)
as
begin


    -- this proc returns 0 to indicate error and 1 to indicate success
    declare @retcode    int
    set nocount on
    declare @rows_deleted int
    declare @rows_remaining int
    declare @error int
    declare @tomb_rows_updated int
    declare @publication_number smallint
    declare @rows_in_syncview int
        
    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin       
        RAISERROR (14126, 11, -1)
        return 0
    end
    
    select @publication_number = 1

    if @rowstobedeleted is NULL or @rowstobedeleted <= 0
        return 0

    begin tran
    save tran batchdeleteproc


    delete [dbo].[member2] with (rowlock)
    from 
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 
) as rows
    inner join [dbo].[member2] t with (rowlock) on rows.rowguid = t.[rowguid] and rows.rowguid is not NULL

    left outer join dbo.MSmerge_contents cont with (rowlock) 
    on rows.rowguid = cont.rowguid and cont.tablenick = 8260001 
    and rows.rowguid is not NULL
    where ((rows.metadata_type = 3 and cont.rowguid is NULL) or
           ((rows.metadata_type = 5 or  rows.metadata_type = 6) and (cont.rowguid is NULL or cont.lineage = rows.lineage_old)) or
           (cont.rowguid is not NULL and cont.lineage = rows.lineage_old))
           and rows.rowguid is not NULL 

    select @rows_deleted = @@rowcount, @error = @@error
    if @error<>0
        goto Failure
    if @rows_deleted > @rowstobedeleted
    begin
        -- this is just not possible
        raiserror(20684, 16, -1, '[dbo].[member2]')
        goto Failure
    end
    if @rows_deleted <> @rowstobedeleted
    begin

        -- we will now check if any of the rows we wanted to delete were not deleted. If the rows were not deleted
        -- by the previous delete because it was already deleted, we will still assume that this is a success
        select @rows_remaining = count(*) from 
        ( 

         select @rowguid1 as rowguid union all 
         select @rowguid2 as rowguid union all 
         select @rowguid3 as rowguid union all 
         select @rowguid4 as rowguid union all 
         select @rowguid5 as rowguid union all 
         select @rowguid6 as rowguid union all 
         select @rowguid7 as rowguid union all 
         select @rowguid8 as rowguid union all 
         select @rowguid9 as rowguid union all 
         select @rowguid10 as rowguid union all 
         select @rowguid11 as rowguid union all 
         select @rowguid12 as rowguid union all 
         select @rowguid13 as rowguid union all 
         select @rowguid14 as rowguid union all 
         select @rowguid15 as rowguid union all 
         select @rowguid16 as rowguid union all 
         select @rowguid17 as rowguid union all 
         select @rowguid18 as rowguid union all 
         select @rowguid19 as rowguid union all 
         select @rowguid20 as rowguid union all 
         select @rowguid21 as rowguid union all 
         select @rowguid22 as rowguid union all 
         select @rowguid23 as rowguid union all 
         select @rowguid24 as rowguid union all 
         select @rowguid25 as rowguid union all 
         select @rowguid26 as rowguid union all 
         select @rowguid27 as rowguid union all 
         select @rowguid28 as rowguid union all 
         select @rowguid29 as rowguid union all 
         select @rowguid30 as rowguid union all 
         select @rowguid31 as rowguid union all 
         select @rowguid32 as rowguid union all 
         select @rowguid33 as rowguid union all 
         select @rowguid34 as rowguid union all 
         select @rowguid35 as rowguid union all 
         select @rowguid36 as rowguid union all 
         select @rowguid37 as rowguid union all 
         select @rowguid38 as rowguid union all 
         select @rowguid39 as rowguid union all 
         select @rowguid40 as rowguid union all 
         select @rowguid41 as rowguid union all 
         select @rowguid42 as rowguid union all 
         select @rowguid43 as rowguid union all 
         select @rowguid44 as rowguid union all 
         select @rowguid45 as rowguid union all 
         select @rowguid46 as rowguid union all 
         select @rowguid47 as rowguid union all 
         select @rowguid48 as rowguid union all 
         select @rowguid49 as rowguid union all 
         select @rowguid50 as rowguid union all

         select @rowguid51 as rowguid union all 
         select @rowguid52 as rowguid union all 
         select @rowguid53 as rowguid union all 
         select @rowguid54 as rowguid union all 
         select @rowguid55 as rowguid union all 
         select @rowguid56 as rowguid union all 
         select @rowguid57 as rowguid union all 
         select @rowguid58 as rowguid union all 
         select @rowguid59 as rowguid union all 
         select @rowguid60 as rowguid union all 
         select @rowguid61 as rowguid union all 
         select @rowguid62 as rowguid union all 
         select @rowguid63 as rowguid union all 
         select @rowguid64 as rowguid union all 
         select @rowguid65 as rowguid union all 
         select @rowguid66 as rowguid union all 
         select @rowguid67 as rowguid union all 
         select @rowguid68 as rowguid union all 
         select @rowguid69 as rowguid union all 
         select @rowguid70 as rowguid union all 
         select @rowguid71 as rowguid union all 
         select @rowguid72 as rowguid union all 
         select @rowguid73 as rowguid union all 
         select @rowguid74 as rowguid union all 
         select @rowguid75 as rowguid union all 
         select @rowguid76 as rowguid union all 
         select @rowguid77 as rowguid union all 
         select @rowguid78 as rowguid union all 
         select @rowguid79 as rowguid union all 
         select @rowguid80 as rowguid union all 
         select @rowguid81 as rowguid union all 
         select @rowguid82 as rowguid union all 
         select @rowguid83 as rowguid union all 
         select @rowguid84 as rowguid union all 
         select @rowguid85 as rowguid union all 
         select @rowguid86 as rowguid union all 
         select @rowguid87 as rowguid union all 
         select @rowguid88 as rowguid union all 
         select @rowguid89 as rowguid union all 
         select @rowguid90 as rowguid union all 
         select @rowguid91 as rowguid union all 
         select @rowguid92 as rowguid union all 
         select @rowguid93 as rowguid union all 
         select @rowguid94 as rowguid union all 
         select @rowguid95 as rowguid union all 
         select @rowguid96 as rowguid union all 
         select @rowguid97 as rowguid union all 
         select @rowguid98 as rowguid union all 
         select @rowguid99 as rowguid union all 
         select @rowguid100 as rowguid

        ) as rows
        inner join [dbo].[member2] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not NULL
        
        if @@error <> 0
            goto Failure
        
        if @rows_remaining <> 0
        begin
            -- failed deleting one or more rows. Could be because of metadata mismatch
            --raiserror(20682, 10, -1, @rows_remaining, '[dbo].[member2]')
            goto Failure
        end        
    end

    -- if we get here it means that all the rows that we intend to delete were either deleted by us
    -- or they were already deleted by someone else and do not exist in the user table
    -- we insert a tombstone entry for the rows we have deleted and delete the contents rows if exists

    -- if the rows were previously deleted we still want to update the metadatatype, generation and lineage
    -- in MSmerge_tombstone. We could find rows in the following update also if the trigger got called by
    -- the user table delete and it inserted the rows into tombstone (it would have inserted with type 1)
    update dbo.MSmerge_tombstone with (rowlock)
        set type = case when (rows.metadata_type=5 or rows.metadata_type=6) then rows.metadata_type else 1 end,
            generation = rows.generation,
            lineage = rows.lineage_new
    from 
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

    ) as rows
    inner join dbo.MSmerge_tombstone tomb with (rowlock) 
    on tomb.rowguid = rows.rowguid and tomb.tablenick = 8260001
    and rows.rowguid is not null
    and rows.lineage_new is not NULL
    option (force order, loop join)
    select @tomb_rows_updated = @@rowcount, @error = @@error
    if @error<>0
        goto Failure

        -- the trigger would have inserted a row in past partition mapping for the currently deleted
        -- row. We need to update that row with the current generation if it exists
        update dbo.MSmerge_past_partition_mappings with (rowlock)
        set generation = rows.generation
    from
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

        ) as rows
        inner join dbo.MSmerge_past_partition_mappings ppm with (rowlock) 
        on ppm.rowguid = rows.rowguid and ppm.tablenick = 8260001 
        and ppm.generation = 0
        and rows.rowguid is not NULL
        and rows.lineage_new is not null
        option (force order, loop join)
        if @error<>0
                goto Failure

    if @tomb_rows_updated <> @rowstobedeleted
    begin
        -- now insert rows that are not in tombstone
        insert into dbo.MSmerge_tombstone with (rowlock)
            (rowguid, tablenick, type, generation, lineage)
        select rows.rowguid, 8260001, 
               case when (rows.metadata_type=5 or rows.metadata_type=6) then rows.metadata_type else 1 end, 
               rows.generation, rows.lineage_new
        from 
        (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

        ) as rows
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid 
        and tomb.tablenick = 8260001
        and rows.rowguid is not NULL and rows.lineage_new is not null
        where tomb.rowguid is NULL 
        and rows.rowguid is not NULL and rows.lineage_new is not null
        
        if @@error<>0
            goto Failure

        -- now delete the contents rows
        delete dbo.MSmerge_contents with (rowlock)
        from 
        (

         select @rowguid1 as rowguid union all 
         select @rowguid2 as rowguid union all 
         select @rowguid3 as rowguid union all 
         select @rowguid4 as rowguid union all 
         select @rowguid5 as rowguid union all 
         select @rowguid6 as rowguid union all 
         select @rowguid7 as rowguid union all 
         select @rowguid8 as rowguid union all 
         select @rowguid9 as rowguid union all 
         select @rowguid10 as rowguid union all 
         select @rowguid11 as rowguid union all 
         select @rowguid12 as rowguid union all 
         select @rowguid13 as rowguid union all 
         select @rowguid14 as rowguid union all 
         select @rowguid15 as rowguid union all 
         select @rowguid16 as rowguid union all 
         select @rowguid17 as rowguid union all 
         select @rowguid18 as rowguid union all 
         select @rowguid19 as rowguid union all 
         select @rowguid20 as rowguid union all 
         select @rowguid21 as rowguid union all 
         select @rowguid22 as rowguid union all 
         select @rowguid23 as rowguid union all 
         select @rowguid24 as rowguid union all 
         select @rowguid25 as rowguid union all 
         select @rowguid26 as rowguid union all 
         select @rowguid27 as rowguid union all 
         select @rowguid28 as rowguid union all 
         select @rowguid29 as rowguid union all 
         select @rowguid30 as rowguid union all 
         select @rowguid31 as rowguid union all 
         select @rowguid32 as rowguid union all 
         select @rowguid33 as rowguid union all 
         select @rowguid34 as rowguid union all 
         select @rowguid35 as rowguid union all 
         select @rowguid36 as rowguid union all 
         select @rowguid37 as rowguid union all 
         select @rowguid38 as rowguid union all 
         select @rowguid39 as rowguid union all 
         select @rowguid40 as rowguid union all 
         select @rowguid41 as rowguid union all 
         select @rowguid42 as rowguid union all 
         select @rowguid43 as rowguid union all 
         select @rowguid44 as rowguid union all 
         select @rowguid45 as rowguid union all 
         select @rowguid46 as rowguid union all 
         select @rowguid47 as rowguid union all 
         select @rowguid48 as rowguid union all 
         select @rowguid49 as rowguid union all 
         select @rowguid50 as rowguid union all

         select @rowguid51 as rowguid union all 
         select @rowguid52 as rowguid union all 
         select @rowguid53 as rowguid union all 
         select @rowguid54 as rowguid union all 
         select @rowguid55 as rowguid union all 
         select @rowguid56 as rowguid union all 
         select @rowguid57 as rowguid union all 
         select @rowguid58 as rowguid union all 
         select @rowguid59 as rowguid union all 
         select @rowguid60 as rowguid union all 
         select @rowguid61 as rowguid union all 
         select @rowguid62 as rowguid union all 
         select @rowguid63 as rowguid union all 
         select @rowguid64 as rowguid union all 
         select @rowguid65 as rowguid union all 
         select @rowguid66 as rowguid union all 
         select @rowguid67 as rowguid union all 
         select @rowguid68 as rowguid union all 
         select @rowguid69 as rowguid union all 
         select @rowguid70 as rowguid union all 
         select @rowguid71 as rowguid union all 
         select @rowguid72 as rowguid union all 
         select @rowguid73 as rowguid union all 
         select @rowguid74 as rowguid union all 
         select @rowguid75 as rowguid union all 
         select @rowguid76 as rowguid union all 
         select @rowguid77 as rowguid union all 
         select @rowguid78 as rowguid union all 
         select @rowguid79 as rowguid union all 
         select @rowguid80 as rowguid union all 
         select @rowguid81 as rowguid union all 
         select @rowguid82 as rowguid union all 
         select @rowguid83 as rowguid union all 
         select @rowguid84 as rowguid union all 
         select @rowguid85 as rowguid union all 
         select @rowguid86 as rowguid union all 
         select @rowguid87 as rowguid union all 
         select @rowguid88 as rowguid union all 
         select @rowguid89 as rowguid union all 
         select @rowguid90 as rowguid union all 
         select @rowguid91 as rowguid union all 
         select @rowguid92 as rowguid union all 
         select @rowguid93 as rowguid union all 
         select @rowguid94 as rowguid union all 
         select @rowguid95 as rowguid union all 
         select @rowguid96 as rowguid union all 
         select @rowguid97 as rowguid union all 
         select @rowguid98 as rowguid union all 
         select @rowguid99 as rowguid union all 
         select @rowguid100 as rowguid

        ) as rows, dbo.MSmerge_contents cont with (rowlock)
        where cont.rowguid = rows.rowguid and cont.tablenick = 8260001
            and rows.rowguid is not NULL
        option (force order, loop join)
        if @@error<>0 
            goto Failure
    end

    exec @retcode = sys.sp_MSdeletemetadataactionrequest 'CEFA968C-E172-41FA-B5A5-680EAD11935A', 8260001, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39, 
        @rowguid40, 
        @rowguid41, 
        @rowguid42, 
        @rowguid43, 
        @rowguid44, 
        @rowguid45, 
        @rowguid46, 
        @rowguid47, 
        @rowguid48, 
        @rowguid49, 
        @rowguid50, 
        @rowguid51, 
        @rowguid52, 
        @rowguid53, 
        @rowguid54, 
        @rowguid55, 
        @rowguid56, 
        @rowguid57, 
        @rowguid58, 
        @rowguid59, 
        @rowguid60, 
        @rowguid61, 
        @rowguid62, 
        @rowguid63, 
        @rowguid64, 
        @rowguid65, 
        @rowguid66, 
        @rowguid67, 
        @rowguid68, 
        @rowguid69, 
        @rowguid70, 
        @rowguid71, 
        @rowguid72, 
        @rowguid73, 
        @rowguid74, 
        @rowguid75, 
        @rowguid76, 
        @rowguid77, 
        @rowguid78, 
        @rowguid79, 
        @rowguid80, 
        @rowguid81, 
        @rowguid82, 
        @rowguid83, 
        @rowguid84, 
        @rowguid85, 
        @rowguid86, 
        @rowguid87, 
        @rowguid88, 
        @rowguid89, 
        @rowguid90, 
        @rowguid91, 
        @rowguid92, 
        @rowguid93, 
        @rowguid94, 
        @rowguid95, 
        @rowguid96, 
        @rowguid97, 
        @rowguid98, 
        @rowguid99, 
        @rowguid100
    if @retcode<>0 or @@error<>0
        goto Failure


    commit tran
    return 1

Failure:
    rollback tran batchdeleteproc
    commit tran
    return 0
end

go
create procedure dbo.[MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA_batch] (
        @rows_tobe_inserted int,
        @partition_id int = null 
,
    @rowguid1 uniqueidentifier = NULL,
    @generation1 bigint = NULL,
    @lineage1 varbinary(311) = NULL,
    @colv1 varbinary(1) = NULL,
    @p1 [numeric_id] = NULL,
    @p2 [shortstring] = NULL,
    @p3 [shortstring] = NULL,
    @p4 [letter] = NULL,
    @p5 [shortstring] = NULL,
    @p6 [shortstring] = NULL,
    @p7 [statecode] = NULL,
    @p8 [countrycode] = NULL,
    @p9 [mailcode] = NULL,
    @p10 [phonenumber] = NULL,
    @p11 image = NULL,
    @p12 datetime = NULL,
    @p13 datetime = NULL,
    @p14 [numeric_id] = NULL,
    @p15 [numeric_id] = NULL,
    @p16 money = NULL,
    @p17 money = NULL,
    @p18 [status_code] = NULL,
    @p19 uniqueidentifier = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @generation2 bigint = NULL,
    @lineage2 varbinary(311) = NULL,
    @colv2 varbinary(1) = NULL,
    @p20 [numeric_id] = NULL,
    @p21 [shortstring] = NULL,
    @p22 [shortstring] = NULL,
    @p23 [letter] = NULL,
    @p24 [shortstring] = NULL,
    @p25 [shortstring] = NULL,
    @p26 [statecode] = NULL,
    @p27 [countrycode] = NULL,
    @p28 [mailcode] = NULL,
    @p29 [phonenumber] = NULL,
    @p30 image = NULL,
    @p31 datetime = NULL,
    @p32 datetime = NULL,
    @p33 [numeric_id] = NULL,
    @p34 [numeric_id] = NULL,
    @p35 money = NULL,
    @p36 money = NULL,
    @p37 [status_code] = NULL,
    @p38 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @generation3 bigint = NULL,
    @lineage3 varbinary(311) = NULL,
    @colv3 varbinary(1) = NULL,
    @p39 [numeric_id] = NULL,
    @p40 [shortstring] = NULL,
    @p41 [shortstring] = NULL,
    @p42 [letter] = NULL,
    @p43 [shortstring] = NULL,
    @p44 [shortstring] = NULL,
    @p45 [statecode] = NULL,
    @p46 [countrycode] = NULL,
    @p47 [mailcode] = NULL,
    @p48 [phonenumber] = NULL,
    @p49 image = NULL,
    @p50 datetime = NULL,
    @p51 datetime = NULL,
    @p52 [numeric_id] = NULL,
    @p53 [numeric_id] = NULL,
    @p54 money = NULL,
    @p55 money = NULL,
    @p56 [status_code] = NULL,
    @p57 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @generation4 bigint = NULL,
    @lineage4 varbinary(311) = NULL,
    @colv4 varbinary(1) = NULL,
    @p58 [numeric_id] = NULL,
    @p59 [shortstring] = NULL,
    @p60 [shortstring] = NULL,
    @p61 [letter] = NULL,
    @p62 [shortstring] = NULL,
    @p63 [shortstring] = NULL,
    @p64 [statecode] = NULL,
    @p65 [countrycode] = NULL,
    @p66 [mailcode] = NULL,
    @p67 [phonenumber] = NULL,
    @p68 image = NULL,
    @p69 datetime = NULL,
    @p70 datetime = NULL,
    @p71 [numeric_id] = NULL,
    @p72 [numeric_id] = NULL,
    @p73 money = NULL,
    @p74 money = NULL,
    @p75 [status_code] = NULL,
    @p76 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @generation5 bigint = NULL,
    @lineage5 varbinary(311) = NULL,
    @colv5 varbinary(1) = NULL,
    @p77 [numeric_id] = NULL,
    @p78 [shortstring] = NULL,
    @p79 [shortstring] = NULL,
    @p80 [letter] = NULL,
    @p81 [shortstring] = NULL,
    @p82 [shortstring] = NULL,
    @p83 [statecode] = NULL,
    @p84 [countrycode] = NULL,
    @p85 [mailcode] = NULL,
    @p86 [phonenumber] = NULL,
    @p87 image = NULL,
    @p88 datetime = NULL,
    @p89 datetime = NULL,
    @p90 [numeric_id] = NULL,
    @p91 [numeric_id] = NULL,
    @p92 money = NULL,
    @p93 money = NULL,
    @p94 [status_code] = NULL,
    @p95 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @generation6 bigint = NULL,
    @lineage6 varbinary(311) = NULL,
    @colv6 varbinary(1) = NULL,
    @p96 [numeric_id] = NULL,
    @p97 [shortstring] = NULL,
    @p98 [shortstring] = NULL
,
    @p99 [letter] = NULL,
    @p100 [shortstring] = NULL,
    @p101 [shortstring] = NULL,
    @p102 [statecode] = NULL,
    @p103 [countrycode] = NULL,
    @p104 [mailcode] = NULL,
    @p105 [phonenumber] = NULL,
    @p106 image = NULL,
    @p107 datetime = NULL,
    @p108 datetime = NULL,
    @p109 [numeric_id] = NULL,
    @p110 [numeric_id] = NULL,
    @p111 money = NULL,
    @p112 money = NULL,
    @p113 [status_code] = NULL,
    @p114 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @generation7 bigint = NULL,
    @lineage7 varbinary(311) = NULL,
    @colv7 varbinary(1) = NULL,
    @p115 [numeric_id] = NULL,
    @p116 [shortstring] = NULL,
    @p117 [shortstring] = NULL,
    @p118 [letter] = NULL,
    @p119 [shortstring] = NULL,
    @p120 [shortstring] = NULL,
    @p121 [statecode] = NULL,
    @p122 [countrycode] = NULL,
    @p123 [mailcode] = NULL,
    @p124 [phonenumber] = NULL,
    @p125 image = NULL,
    @p126 datetime = NULL,
    @p127 datetime = NULL,
    @p128 [numeric_id] = NULL,
    @p129 [numeric_id] = NULL,
    @p130 money = NULL,
    @p131 money = NULL,
    @p132 [status_code] = NULL,
    @p133 uniqueidentifier = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @generation8 bigint = NULL,
    @lineage8 varbinary(311) = NULL,
    @colv8 varbinary(1) = NULL,
    @p134 [numeric_id] = NULL,
    @p135 [shortstring] = NULL,
    @p136 [shortstring] = NULL,
    @p137 [letter] = NULL,
    @p138 [shortstring] = NULL,
    @p139 [shortstring] = NULL,
    @p140 [statecode] = NULL,
    @p141 [countrycode] = NULL,
    @p142 [mailcode] = NULL,
    @p143 [phonenumber] = NULL,
    @p144 image = NULL,
    @p145 datetime = NULL,
    @p146 datetime = NULL,
    @p147 [numeric_id] = NULL,
    @p148 [numeric_id] = NULL,
    @p149 money = NULL,
    @p150 money = NULL,
    @p151 [status_code] = NULL,
    @p152 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @generation9 bigint = NULL,
    @lineage9 varbinary(311) = NULL,
    @colv9 varbinary(1) = NULL,
    @p153 [numeric_id] = NULL,
    @p154 [shortstring] = NULL,
    @p155 [shortstring] = NULL,
    @p156 [letter] = NULL,
    @p157 [shortstring] = NULL,
    @p158 [shortstring] = NULL,
    @p159 [statecode] = NULL,
    @p160 [countrycode] = NULL,
    @p161 [mailcode] = NULL,
    @p162 [phonenumber] = NULL,
    @p163 image = NULL,
    @p164 datetime = NULL,
    @p165 datetime = NULL,
    @p166 [numeric_id] = NULL,
    @p167 [numeric_id] = NULL,
    @p168 money = NULL,
    @p169 money = NULL,
    @p170 [status_code] = NULL,
    @p171 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @generation10 bigint = NULL,
    @lineage10 varbinary(311) = NULL,
    @colv10 varbinary(1) = NULL,
    @p172 [numeric_id] = NULL,
    @p173 [shortstring] = NULL,
    @p174 [shortstring] = NULL,
    @p175 [letter] = NULL,
    @p176 [shortstring] = NULL,
    @p177 [shortstring] = NULL,
    @p178 [statecode] = NULL,
    @p179 [countrycode] = NULL,
    @p180 [mailcode] = NULL,
    @p181 [phonenumber] = NULL,
    @p182 image = NULL,
    @p183 datetime = NULL,
    @p184 datetime = NULL,
    @p185 [numeric_id] = NULL,
    @p186 [numeric_id] = NULL,
    @p187 money = NULL,
    @p188 money = NULL,
    @p189 [status_code] = NULL,
    @p190 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @generation11 bigint = NULL,
    @lineage11 varbinary(311) = NULL,
    @colv11 varbinary(1) = NULL,
    @p191 [numeric_id] = NULL,
    @p192 [shortstring] = NULL,
    @p193 [shortstring] = NULL,
    @p194 [letter] = NULL,
    @p195 [shortstring] = NULL,
    @p196 [shortstring] = NULL,
    @p197 [statecode] = NULL
,
    @p198 [countrycode] = NULL,
    @p199 [mailcode] = NULL,
    @p200 [phonenumber] = NULL,
    @p201 image = NULL,
    @p202 datetime = NULL,
    @p203 datetime = NULL,
    @p204 [numeric_id] = NULL,
    @p205 [numeric_id] = NULL,
    @p206 money = NULL,
    @p207 money = NULL,
    @p208 [status_code] = NULL,
    @p209 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @generation12 bigint = NULL,
    @lineage12 varbinary(311) = NULL,
    @colv12 varbinary(1) = NULL,
    @p210 [numeric_id] = NULL,
    @p211 [shortstring] = NULL,
    @p212 [shortstring] = NULL,
    @p213 [letter] = NULL,
    @p214 [shortstring] = NULL,
    @p215 [shortstring] = NULL,
    @p216 [statecode] = NULL,
    @p217 [countrycode] = NULL,
    @p218 [mailcode] = NULL,
    @p219 [phonenumber] = NULL,
    @p220 image = NULL,
    @p221 datetime = NULL,
    @p222 datetime = NULL,
    @p223 [numeric_id] = NULL,
    @p224 [numeric_id] = NULL,
    @p225 money = NULL,
    @p226 money = NULL,
    @p227 [status_code] = NULL,
    @p228 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @generation13 bigint = NULL,
    @lineage13 varbinary(311) = NULL,
    @colv13 varbinary(1) = NULL,
    @p229 [numeric_id] = NULL,
    @p230 [shortstring] = NULL,
    @p231 [shortstring] = NULL,
    @p232 [letter] = NULL,
    @p233 [shortstring] = NULL,
    @p234 [shortstring] = NULL,
    @p235 [statecode] = NULL,
    @p236 [countrycode] = NULL,
    @p237 [mailcode] = NULL,
    @p238 [phonenumber] = NULL,
    @p239 image = NULL,
    @p240 datetime = NULL,
    @p241 datetime = NULL,
    @p242 [numeric_id] = NULL,
    @p243 [numeric_id] = NULL,
    @p244 money = NULL,
    @p245 money = NULL,
    @p246 [status_code] = NULL,
    @p247 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @generation14 bigint = NULL,
    @lineage14 varbinary(311) = NULL,
    @colv14 varbinary(1) = NULL,
    @p248 [numeric_id] = NULL,
    @p249 [shortstring] = NULL,
    @p250 [shortstring] = NULL,
    @p251 [letter] = NULL,
    @p252 [shortstring] = NULL,
    @p253 [shortstring] = NULL,
    @p254 [statecode] = NULL,
    @p255 [countrycode] = NULL,
    @p256 [mailcode] = NULL,
    @p257 [phonenumber] = NULL,
    @p258 image = NULL,
    @p259 datetime = NULL,
    @p260 datetime = NULL,
    @p261 [numeric_id] = NULL,
    @p262 [numeric_id] = NULL,
    @p263 money = NULL,
    @p264 money = NULL,
    @p265 [status_code] = NULL,
    @p266 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @generation15 bigint = NULL,
    @lineage15 varbinary(311) = NULL,
    @colv15 varbinary(1) = NULL,
    @p267 [numeric_id] = NULL,
    @p268 [shortstring] = NULL,
    @p269 [shortstring] = NULL,
    @p270 [letter] = NULL,
    @p271 [shortstring] = NULL,
    @p272 [shortstring] = NULL,
    @p273 [statecode] = NULL,
    @p274 [countrycode] = NULL,
    @p275 [mailcode] = NULL,
    @p276 [phonenumber] = NULL,
    @p277 image = NULL,
    @p278 datetime = NULL,
    @p279 datetime = NULL,
    @p280 [numeric_id] = NULL,
    @p281 [numeric_id] = NULL,
    @p282 money = NULL,
    @p283 money = NULL,
    @p284 [status_code] = NULL,
    @p285 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @generation16 bigint = NULL,
    @lineage16 varbinary(311) = NULL,
    @colv16 varbinary(1) = NULL,
    @p286 [numeric_id] = NULL,
    @p287 [shortstring] = NULL,
    @p288 [shortstring] = NULL,
    @p289 [letter] = NULL,
    @p290 [shortstring] = NULL,
    @p291 [shortstring] = NULL,
    @p292 [statecode] = NULL,
    @p293 [countrycode] = NULL,
    @p294 [mailcode] = NULL,
    @p295 [phonenumber] = NULL
,
    @p296 image = NULL,
    @p297 datetime = NULL,
    @p298 datetime = NULL,
    @p299 [numeric_id] = NULL,
    @p300 [numeric_id] = NULL,
    @p301 money = NULL,
    @p302 money = NULL,
    @p303 [status_code] = NULL,
    @p304 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @generation17 bigint = NULL,
    @lineage17 varbinary(311) = NULL,
    @colv17 varbinary(1) = NULL,
    @p305 [numeric_id] = NULL,
    @p306 [shortstring] = NULL,
    @p307 [shortstring] = NULL,
    @p308 [letter] = NULL,
    @p309 [shortstring] = NULL,
    @p310 [shortstring] = NULL,
    @p311 [statecode] = NULL,
    @p312 [countrycode] = NULL,
    @p313 [mailcode] = NULL,
    @p314 [phonenumber] = NULL,
    @p315 image = NULL,
    @p316 datetime = NULL,
    @p317 datetime = NULL,
    @p318 [numeric_id] = NULL,
    @p319 [numeric_id] = NULL,
    @p320 money = NULL,
    @p321 money = NULL,
    @p322 [status_code] = NULL,
    @p323 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @generation18 bigint = NULL,
    @lineage18 varbinary(311) = NULL,
    @colv18 varbinary(1) = NULL,
    @p324 [numeric_id] = NULL,
    @p325 [shortstring] = NULL,
    @p326 [shortstring] = NULL,
    @p327 [letter] = NULL,
    @p328 [shortstring] = NULL,
    @p329 [shortstring] = NULL,
    @p330 [statecode] = NULL,
    @p331 [countrycode] = NULL,
    @p332 [mailcode] = NULL,
    @p333 [phonenumber] = NULL,
    @p334 image = NULL,
    @p335 datetime = NULL,
    @p336 datetime = NULL,
    @p337 [numeric_id] = NULL,
    @p338 [numeric_id] = NULL,
    @p339 money = NULL,
    @p340 money = NULL,
    @p341 [status_code] = NULL,
    @p342 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @generation19 bigint = NULL,
    @lineage19 varbinary(311) = NULL,
    @colv19 varbinary(1) = NULL,
    @p343 [numeric_id] = NULL,
    @p344 [shortstring] = NULL,
    @p345 [shortstring] = NULL,
    @p346 [letter] = NULL,
    @p347 [shortstring] = NULL,
    @p348 [shortstring] = NULL,
    @p349 [statecode] = NULL,
    @p350 [countrycode] = NULL,
    @p351 [mailcode] = NULL,
    @p352 [phonenumber] = NULL,
    @p353 image = NULL,
    @p354 datetime = NULL,
    @p355 datetime = NULL,
    @p356 [numeric_id] = NULL,
    @p357 [numeric_id] = NULL,
    @p358 money = NULL,
    @p359 money = NULL,
    @p360 [status_code] = NULL,
    @p361 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @generation20 bigint = NULL,
    @lineage20 varbinary(311) = NULL,
    @colv20 varbinary(1) = NULL,
    @p362 [numeric_id] = NULL,
    @p363 [shortstring] = NULL,
    @p364 [shortstring] = NULL,
    @p365 [letter] = NULL,
    @p366 [shortstring] = NULL,
    @p367 [shortstring] = NULL,
    @p368 [statecode] = NULL,
    @p369 [countrycode] = NULL,
    @p370 [mailcode] = NULL,
    @p371 [phonenumber] = NULL,
    @p372 image = NULL,
    @p373 datetime = NULL,
    @p374 datetime = NULL,
    @p375 [numeric_id] = NULL,
    @p376 [numeric_id] = NULL,
    @p377 money = NULL,
    @p378 money = NULL,
    @p379 [status_code] = NULL,
    @p380 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @generation21 bigint = NULL,
    @lineage21 varbinary(311) = NULL,
    @colv21 varbinary(1) = NULL,
    @p381 [numeric_id] = NULL,
    @p382 [shortstring] = NULL,
    @p383 [shortstring] = NULL,
    @p384 [letter] = NULL,
    @p385 [shortstring] = NULL,
    @p386 [shortstring] = NULL,
    @p387 [statecode] = NULL,
    @p388 [countrycode] = NULL,
    @p389 [mailcode] = NULL,
    @p390 [phonenumber] = NULL,
    @p391 image = NULL,
    @p392 datetime = NULL,
    @p393 datetime = NULL,
    @p394 [numeric_id] = NULL
,
    @p395 [numeric_id] = NULL,
    @p396 money = NULL,
    @p397 money = NULL,
    @p398 [status_code] = NULL,
    @p399 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @generation22 bigint = NULL,
    @lineage22 varbinary(311) = NULL,
    @colv22 varbinary(1) = NULL,
    @p400 [numeric_id] = NULL,
    @p401 [shortstring] = NULL,
    @p402 [shortstring] = NULL,
    @p403 [letter] = NULL,
    @p404 [shortstring] = NULL,
    @p405 [shortstring] = NULL,
    @p406 [statecode] = NULL,
    @p407 [countrycode] = NULL,
    @p408 [mailcode] = NULL,
    @p409 [phonenumber] = NULL,
    @p410 image = NULL,
    @p411 datetime = NULL,
    @p412 datetime = NULL,
    @p413 [numeric_id] = NULL,
    @p414 [numeric_id] = NULL,
    @p415 money = NULL,
    @p416 money = NULL,
    @p417 [status_code] = NULL,
    @p418 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @generation23 bigint = NULL,
    @lineage23 varbinary(311) = NULL,
    @colv23 varbinary(1) = NULL,
    @p419 [numeric_id] = NULL,
    @p420 [shortstring] = NULL,
    @p421 [shortstring] = NULL,
    @p422 [letter] = NULL,
    @p423 [shortstring] = NULL,
    @p424 [shortstring] = NULL,
    @p425 [statecode] = NULL,
    @p426 [countrycode] = NULL,
    @p427 [mailcode] = NULL,
    @p428 [phonenumber] = NULL,
    @p429 image = NULL,
    @p430 datetime = NULL,
    @p431 datetime = NULL,
    @p432 [numeric_id] = NULL,
    @p433 [numeric_id] = NULL,
    @p434 money = NULL,
    @p435 money = NULL,
    @p436 [status_code] = NULL,
    @p437 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @generation24 bigint = NULL,
    @lineage24 varbinary(311) = NULL,
    @colv24 varbinary(1) = NULL,
    @p438 [numeric_id] = NULL,
    @p439 [shortstring] = NULL,
    @p440 [shortstring] = NULL,
    @p441 [letter] = NULL,
    @p442 [shortstring] = NULL,
    @p443 [shortstring] = NULL,
    @p444 [statecode] = NULL,
    @p445 [countrycode] = NULL,
    @p446 [mailcode] = NULL,
    @p447 [phonenumber] = NULL,
    @p448 image = NULL,
    @p449 datetime = NULL,
    @p450 datetime = NULL,
    @p451 [numeric_id] = NULL,
    @p452 [numeric_id] = NULL,
    @p453 money = NULL,
    @p454 money = NULL,
    @p455 [status_code] = NULL,
    @p456 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @generation25 bigint = NULL,
    @lineage25 varbinary(311) = NULL,
    @colv25 varbinary(1) = NULL,
    @p457 [numeric_id] = NULL,
    @p458 [shortstring] = NULL,
    @p459 [shortstring] = NULL,
    @p460 [letter] = NULL,
    @p461 [shortstring] = NULL,
    @p462 [shortstring] = NULL,
    @p463 [statecode] = NULL,
    @p464 [countrycode] = NULL,
    @p465 [mailcode] = NULL,
    @p466 [phonenumber] = NULL,
    @p467 image = NULL,
    @p468 datetime = NULL,
    @p469 datetime = NULL,
    @p470 [numeric_id] = NULL,
    @p471 [numeric_id] = NULL,
    @p472 money = NULL,
    @p473 money = NULL,
    @p474 [status_code] = NULL,
    @p475 uniqueidentifier = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @generation26 bigint = NULL,
    @lineage26 varbinary(311) = NULL,
    @colv26 varbinary(1) = NULL,
    @p476 [numeric_id] = NULL,
    @p477 [shortstring] = NULL,
    @p478 [shortstring] = NULL,
    @p479 [letter] = NULL,
    @p480 [shortstring] = NULL,
    @p481 [shortstring] = NULL,
    @p482 [statecode] = NULL,
    @p483 [countrycode] = NULL,
    @p484 [mailcode] = NULL,
    @p485 [phonenumber] = NULL,
    @p486 image = NULL,
    @p487 datetime = NULL,
    @p488 datetime = NULL,
    @p489 [numeric_id] = NULL,
    @p490 [numeric_id] = NULL,
    @p491 money = NULL,
    @p492 money = NULL,
    @p493 [status_code] = NULL
,
    @p494 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @generation27 bigint = NULL,
    @lineage27 varbinary(311) = NULL,
    @colv27 varbinary(1) = NULL,
    @p495 [numeric_id] = NULL,
    @p496 [shortstring] = NULL,
    @p497 [shortstring] = NULL,
    @p498 [letter] = NULL,
    @p499 [shortstring] = NULL,
    @p500 [shortstring] = NULL,
    @p501 [statecode] = NULL,
    @p502 [countrycode] = NULL,
    @p503 [mailcode] = NULL,
    @p504 [phonenumber] = NULL,
    @p505 image = NULL,
    @p506 datetime = NULL,
    @p507 datetime = NULL,
    @p508 [numeric_id] = NULL,
    @p509 [numeric_id] = NULL,
    @p510 money = NULL,
    @p511 money = NULL,
    @p512 [status_code] = NULL,
    @p513 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @generation28 bigint = NULL,
    @lineage28 varbinary(311) = NULL,
    @colv28 varbinary(1) = NULL,
    @p514 [numeric_id] = NULL,
    @p515 [shortstring] = NULL,
    @p516 [shortstring] = NULL,
    @p517 [letter] = NULL,
    @p518 [shortstring] = NULL,
    @p519 [shortstring] = NULL,
    @p520 [statecode] = NULL,
    @p521 [countrycode] = NULL,
    @p522 [mailcode] = NULL,
    @p523 [phonenumber] = NULL,
    @p524 image = NULL,
    @p525 datetime = NULL,
    @p526 datetime = NULL,
    @p527 [numeric_id] = NULL,
    @p528 [numeric_id] = NULL,
    @p529 money = NULL,
    @p530 money = NULL,
    @p531 [status_code] = NULL,
    @p532 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @generation29 bigint = NULL,
    @lineage29 varbinary(311) = NULL,
    @colv29 varbinary(1) = NULL,
    @p533 [numeric_id] = NULL,
    @p534 [shortstring] = NULL,
    @p535 [shortstring] = NULL,
    @p536 [letter] = NULL,
    @p537 [shortstring] = NULL,
    @p538 [shortstring] = NULL,
    @p539 [statecode] = NULL,
    @p540 [countrycode] = NULL,
    @p541 [mailcode] = NULL,
    @p542 [phonenumber] = NULL,
    @p543 image = NULL,
    @p544 datetime = NULL,
    @p545 datetime = NULL,
    @p546 [numeric_id] = NULL,
    @p547 [numeric_id] = NULL,
    @p548 money = NULL,
    @p549 money = NULL,
    @p550 [status_code] = NULL,
    @p551 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @generation30 bigint = NULL,
    @lineage30 varbinary(311) = NULL,
    @colv30 varbinary(1) = NULL,
    @p552 [numeric_id] = NULL,
    @p553 [shortstring] = NULL,
    @p554 [shortstring] = NULL,
    @p555 [letter] = NULL,
    @p556 [shortstring] = NULL,
    @p557 [shortstring] = NULL,
    @p558 [statecode] = NULL,
    @p559 [countrycode] = NULL,
    @p560 [mailcode] = NULL,
    @p561 [phonenumber] = NULL,
    @p562 image = NULL,
    @p563 datetime = NULL,
    @p564 datetime = NULL,
    @p565 [numeric_id] = NULL,
    @p566 [numeric_id] = NULL,
    @p567 money = NULL,
    @p568 money = NULL,
    @p569 [status_code] = NULL,
    @p570 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @generation31 bigint = NULL,
    @lineage31 varbinary(311) = NULL,
    @colv31 varbinary(1) = NULL,
    @p571 [numeric_id] = NULL,
    @p572 [shortstring] = NULL,
    @p573 [shortstring] = NULL,
    @p574 [letter] = NULL,
    @p575 [shortstring] = NULL,
    @p576 [shortstring] = NULL,
    @p577 [statecode] = NULL,
    @p578 [countrycode] = NULL,
    @p579 [mailcode] = NULL,
    @p580 [phonenumber] = NULL,
    @p581 image = NULL,
    @p582 datetime = NULL,
    @p583 datetime = NULL,
    @p584 [numeric_id] = NULL,
    @p585 [numeric_id] = NULL,
    @p586 money = NULL,
    @p587 money = NULL,
    @p588 [status_code] = NULL,
    @p589 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @generation32 bigint = NULL,
    @lineage32 varbinary(311) = NULL,
    @colv32 varbinary(1) = NULL,
    @p590 [numeric_id] = NULL
,
    @p591 [shortstring] = NULL,
    @p592 [shortstring] = NULL,
    @p593 [letter] = NULL,
    @p594 [shortstring] = NULL,
    @p595 [shortstring] = NULL,
    @p596 [statecode] = NULL,
    @p597 [countrycode] = NULL,
    @p598 [mailcode] = NULL,
    @p599 [phonenumber] = NULL,
    @p600 image = NULL,
    @p601 datetime = NULL,
    @p602 datetime = NULL,
    @p603 [numeric_id] = NULL,
    @p604 [numeric_id] = NULL,
    @p605 money = NULL,
    @p606 money = NULL,
    @p607 [status_code] = NULL,
    @p608 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @generation33 bigint = NULL,
    @lineage33 varbinary(311) = NULL,
    @colv33 varbinary(1) = NULL,
    @p609 [numeric_id] = NULL,
    @p610 [shortstring] = NULL,
    @p611 [shortstring] = NULL,
    @p612 [letter] = NULL,
    @p613 [shortstring] = NULL,
    @p614 [shortstring] = NULL,
    @p615 [statecode] = NULL,
    @p616 [countrycode] = NULL,
    @p617 [mailcode] = NULL,
    @p618 [phonenumber] = NULL,
    @p619 image = NULL,
    @p620 datetime = NULL,
    @p621 datetime = NULL,
    @p622 [numeric_id] = NULL,
    @p623 [numeric_id] = NULL,
    @p624 money = NULL,
    @p625 money = NULL,
    @p626 [status_code] = NULL,
    @p627 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @generation34 bigint = NULL,
    @lineage34 varbinary(311) = NULL,
    @colv34 varbinary(1) = NULL,
    @p628 [numeric_id] = NULL,
    @p629 [shortstring] = NULL,
    @p630 [shortstring] = NULL,
    @p631 [letter] = NULL,
    @p632 [shortstring] = NULL,
    @p633 [shortstring] = NULL,
    @p634 [statecode] = NULL,
    @p635 [countrycode] = NULL,
    @p636 [mailcode] = NULL,
    @p637 [phonenumber] = NULL,
    @p638 image = NULL,
    @p639 datetime = NULL,
    @p640 datetime = NULL,
    @p641 [numeric_id] = NULL,
    @p642 [numeric_id] = NULL,
    @p643 money = NULL,
    @p644 money = NULL,
    @p645 [status_code] = NULL,
    @p646 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @generation35 bigint = NULL,
    @lineage35 varbinary(311) = NULL,
    @colv35 varbinary(1) = NULL,
    @p647 [numeric_id] = NULL,
    @p648 [shortstring] = NULL,
    @p649 [shortstring] = NULL,
    @p650 [letter] = NULL,
    @p651 [shortstring] = NULL,
    @p652 [shortstring] = NULL,
    @p653 [statecode] = NULL,
    @p654 [countrycode] = NULL,
    @p655 [mailcode] = NULL,
    @p656 [phonenumber] = NULL,
    @p657 image = NULL,
    @p658 datetime = NULL,
    @p659 datetime = NULL,
    @p660 [numeric_id] = NULL,
    @p661 [numeric_id] = NULL,
    @p662 money = NULL,
    @p663 money = NULL,
    @p664 [status_code] = NULL,
    @p665 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @generation36 bigint = NULL,
    @lineage36 varbinary(311) = NULL,
    @colv36 varbinary(1) = NULL,
    @p666 [numeric_id] = NULL,
    @p667 [shortstring] = NULL,
    @p668 [shortstring] = NULL,
    @p669 [letter] = NULL,
    @p670 [shortstring] = NULL,
    @p671 [shortstring] = NULL,
    @p672 [statecode] = NULL,
    @p673 [countrycode] = NULL,
    @p674 [mailcode] = NULL,
    @p675 [phonenumber] = NULL,
    @p676 image = NULL,
    @p677 datetime = NULL,
    @p678 datetime = NULL,
    @p679 [numeric_id] = NULL,
    @p680 [numeric_id] = NULL,
    @p681 money = NULL,
    @p682 money = NULL,
    @p683 [status_code] = NULL,
    @p684 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @generation37 bigint = NULL,
    @lineage37 varbinary(311) = NULL,
    @colv37 varbinary(1) = NULL,
    @p685 [numeric_id] = NULL,
    @p686 [shortstring] = NULL,
    @p687 [shortstring] = NULL,
    @p688 [letter] = NULL,
    @p689 [shortstring] = NULL
,
    @p690 [shortstring] = NULL,
    @p691 [statecode] = NULL,
    @p692 [countrycode] = NULL,
    @p693 [mailcode] = NULL,
    @p694 [phonenumber] = NULL,
    @p695 image = NULL,
    @p696 datetime = NULL,
    @p697 datetime = NULL,
    @p698 [numeric_id] = NULL,
    @p699 [numeric_id] = NULL,
    @p700 money = NULL,
    @p701 money = NULL,
    @p702 [status_code] = NULL,
    @p703 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @generation38 bigint = NULL,
    @lineage38 varbinary(311) = NULL,
    @colv38 varbinary(1) = NULL,
    @p704 [numeric_id] = NULL,
    @p705 [shortstring] = NULL,
    @p706 [shortstring] = NULL,
    @p707 [letter] = NULL,
    @p708 [shortstring] = NULL,
    @p709 [shortstring] = NULL,
    @p710 [statecode] = NULL,
    @p711 [countrycode] = NULL,
    @p712 [mailcode] = NULL,
    @p713 [phonenumber] = NULL,
    @p714 image = NULL,
    @p715 datetime = NULL,
    @p716 datetime = NULL,
    @p717 [numeric_id] = NULL,
    @p718 [numeric_id] = NULL,
    @p719 money = NULL,
    @p720 money = NULL,
    @p721 [status_code] = NULL,
    @p722 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @generation39 bigint = NULL,
    @lineage39 varbinary(311) = NULL,
    @colv39 varbinary(1) = NULL,
    @p723 [numeric_id] = NULL,
    @p724 [shortstring] = NULL,
    @p725 [shortstring] = NULL,
    @p726 [letter] = NULL,
    @p727 [shortstring] = NULL,
    @p728 [shortstring] = NULL,
    @p729 [statecode] = NULL,
    @p730 [countrycode] = NULL,
    @p731 [mailcode] = NULL,
    @p732 [phonenumber] = NULL,
    @p733 image = NULL,
    @p734 datetime = NULL,
    @p735 datetime = NULL,
    @p736 [numeric_id] = NULL,
    @p737 [numeric_id] = NULL,
    @p738 money = NULL,
    @p739 money = NULL,
    @p740 [status_code] = NULL,
    @p741 uniqueidentifier = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @generation40 bigint = NULL,
    @lineage40 varbinary(311) = NULL,
    @colv40 varbinary(1) = NULL,
    @p742 [numeric_id] = NULL,
    @p743 [shortstring] = NULL,
    @p744 [shortstring] = NULL,
    @p745 [letter] = NULL,
    @p746 [shortstring] = NULL,
    @p747 [shortstring] = NULL,
    @p748 [statecode] = NULL,
    @p749 [countrycode] = NULL,
    @p750 [mailcode] = NULL,
    @p751 [phonenumber] = NULL,
    @p752 image = NULL,
    @p753 datetime = NULL,
    @p754 datetime = NULL,
    @p755 [numeric_id] = NULL,
    @p756 [numeric_id] = NULL,
    @p757 money = NULL,
    @p758 money = NULL,
    @p759 [status_code] = NULL,
    @p760 uniqueidentifier = NULL,
    @rowguid41 uniqueidentifier = NULL,
    @generation41 bigint = NULL,
    @lineage41 varbinary(311) = NULL,
    @colv41 varbinary(1) = NULL,
    @p761 [numeric_id] = NULL,
    @p762 [shortstring] = NULL,
    @p763 [shortstring] = NULL,
    @p764 [letter] = NULL,
    @p765 [shortstring] = NULL,
    @p766 [shortstring] = NULL,
    @p767 [statecode] = NULL,
    @p768 [countrycode] = NULL,
    @p769 [mailcode] = NULL,
    @p770 [phonenumber] = NULL,
    @p771 image = NULL,
    @p772 datetime = NULL,
    @p773 datetime = NULL,
    @p774 [numeric_id] = NULL,
    @p775 [numeric_id] = NULL,
    @p776 money = NULL,
    @p777 money = NULL,
    @p778 [status_code] = NULL,
    @p779 uniqueidentifier = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @generation42 bigint = NULL,
    @lineage42 varbinary(311) = NULL,
    @colv42 varbinary(1) = NULL,
    @p780 [numeric_id] = NULL,
    @p781 [shortstring] = NULL,
    @p782 [shortstring] = NULL,
    @p783 [letter] = NULL,
    @p784 [shortstring] = NULL,
    @p785 [shortstring] = NULL,
    @p786 [statecode] = NULL,
    @p787 [countrycode] = NULL
,
    @p788 [mailcode] = NULL,
    @p789 [phonenumber] = NULL,
    @p790 image = NULL,
    @p791 datetime = NULL,
    @p792 datetime = NULL,
    @p793 [numeric_id] = NULL,
    @p794 [numeric_id] = NULL,
    @p795 money = NULL,
    @p796 money = NULL,
    @p797 [status_code] = NULL,
    @p798 uniqueidentifier = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @generation43 bigint = NULL,
    @lineage43 varbinary(311) = NULL,
    @colv43 varbinary(1) = NULL,
    @p799 [numeric_id] = NULL,
    @p800 [shortstring] = NULL,
    @p801 [shortstring] = NULL,
    @p802 [letter] = NULL,
    @p803 [shortstring] = NULL,
    @p804 [shortstring] = NULL,
    @p805 [statecode] = NULL,
    @p806 [countrycode] = NULL,
    @p807 [mailcode] = NULL,
    @p808 [phonenumber] = NULL,
    @p809 image = NULL,
    @p810 datetime = NULL,
    @p811 datetime = NULL,
    @p812 [numeric_id] = NULL,
    @p813 [numeric_id] = NULL,
    @p814 money = NULL,
    @p815 money = NULL,
    @p816 [status_code] = NULL,
    @p817 uniqueidentifier = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @generation44 bigint = NULL,
    @lineage44 varbinary(311) = NULL,
    @colv44 varbinary(1) = NULL,
    @p818 [numeric_id] = NULL
,
    @p819 [shortstring] = NULL
,
    @p820 [shortstring] = NULL
,
    @p821 [letter] = NULL
,
    @p822 [shortstring] = NULL
,
    @p823 [shortstring] = NULL
,
    @p824 [statecode] = NULL
,
    @p825 [countrycode] = NULL
,
    @p826 [mailcode] = NULL
,
    @p827 [phonenumber] = NULL
,
    @p828 image = NULL
,
    @p829 datetime = NULL
,
    @p830 datetime = NULL
,
    @p831 [numeric_id] = NULL
,
    @p832 [numeric_id] = NULL
,
    @p833 money = NULL
,
    @p834 money = NULL
,
    @p835 [status_code] = NULL
,
    @p836 uniqueidentifier = NULL

) as
begin
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @rows_in_contents int
    declare @rows_inserted_into_contents int
    declare @publication_number smallint
    declare @gen_cur bigint
    declare @rows_in_tomb bit
    declare @rows_in_syncview int
    declare @marker uniqueidentifier
    
    set nocount on
    
    set @errcode= 0
    set @publication_number = 1
    
    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    if @rows_tobe_inserted is NULL or @rows_tobe_inserted <=0
        return 0



    begin tran
    save tran batchinsertproc 

    exec @retcode = sys.sp_MSmerge_getgencur_public 8260001, @rows_tobe_inserted, @gen_cur output
    if @retcode<>0 or @@error<>0
        return 4



    select @rows_in_tomb = 0
    select @rows_in_tomb = 1 from (

         select @rowguid1 as rowguid
 union all 
         select @rowguid2 as rowguid
 union all 
         select @rowguid3 as rowguid
 union all 
         select @rowguid4 as rowguid
 union all 
         select @rowguid5 as rowguid
 union all 
         select @rowguid6 as rowguid
 union all 
         select @rowguid7 as rowguid
 union all 
         select @rowguid8 as rowguid
 union all 
         select @rowguid9 as rowguid
 union all 
         select @rowguid10 as rowguid
 union all 
         select @rowguid11 as rowguid
 union all 
         select @rowguid12 as rowguid
 union all 
         select @rowguid13 as rowguid
 union all 
         select @rowguid14 as rowguid
 union all 
         select @rowguid15 as rowguid
 union all 
         select @rowguid16 as rowguid
 union all 
         select @rowguid17 as rowguid
 union all 
         select @rowguid18 as rowguid
 union all 
         select @rowguid19 as rowguid
 union all 
         select @rowguid20 as rowguid
 union all 
         select @rowguid21 as rowguid
 union all 
         select @rowguid22 as rowguid
 union all 
         select @rowguid23 as rowguid
 union all 
         select @rowguid24 as rowguid
 union all 
         select @rowguid25 as rowguid
 union all 
         select @rowguid26 as rowguid
 union all 
         select @rowguid27 as rowguid
 union all 
         select @rowguid28 as rowguid
 union all 
         select @rowguid29 as rowguid
 union all 
         select @rowguid30 as rowguid
 union all 
         select @rowguid31 as rowguid
 union all 
         select @rowguid32 as rowguid
 union all 
         select @rowguid33 as rowguid
 union all 
         select @rowguid34 as rowguid
 union all 
         select @rowguid35 as rowguid
 union all 
         select @rowguid36 as rowguid
 union all 
         select @rowguid37 as rowguid
 union all 
         select @rowguid38 as rowguid
 union all 
         select @rowguid39 as rowguid
 union all 
         select @rowguid40 as rowguid
 union all 
         select @rowguid41 as rowguid
 union all 
         select @rowguid42 as rowguid
 union all 
         select @rowguid43 as rowguid
 union all 
         select @rowguid44 as rowguid

    ) as rows
    inner join dbo.MSmerge_tombstone tomb with (rowlock) 
    on tomb.rowguid = rows.rowguid
    and tomb.tablenick = 8260001
    and rows.rowguid is not NULL
        
    if @rows_in_tomb = 1
    begin
        raiserror(20692, 16, -1, 'member2')
        set @errcode=3
        goto Failure
    end

    
    select @marker = newid()
    insert into dbo.MSmerge_contents with (rowlock)
    (rowguid, tablenick, generation, partchangegen, lineage, colv1, marker)
    select rows.rowguid, 8260001, rows.generation, (-rows.generation), rows.lineage, rows.colv, @marker
    from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage1 as lineage, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage2 as lineage, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage3 as lineage, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage4 as lineage, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage5 as lineage, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage6 as lineage, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage7 as lineage, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage8 as lineage, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage9 as lineage, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage10 as lineage, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage11 as lineage, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage12 as lineage, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage13 as lineage, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage14 as lineage, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage15 as lineage, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage16 as lineage, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage17 as lineage, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage18 as lineage, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage19 as lineage, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage20 as lineage, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage21 as lineage, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage22 as lineage, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage23 as lineage, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage24 as lineage, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage25 as lineage, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage26 as lineage, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage27 as lineage, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage28 as lineage, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage29 as lineage, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage30 as lineage, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage31 as lineage, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage32 as lineage, @colv32 as colv union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage33 as lineage, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage34 as lineage, @colv34 as colv
 union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage35 as lineage, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage36 as lineage, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage37 as lineage, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage38 as lineage, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage39 as lineage, @colv39 as colv union all
    select @rowguid40 as rowguid, @generation40 as generation, @lineage40 as lineage, @colv40 as colv union all
    select @rowguid41 as rowguid, @generation41 as generation, @lineage41 as lineage, @colv41 as colv union all
    select @rowguid42 as rowguid, @generation42 as generation, @lineage42 as lineage, @colv42 as colv union all
    select @rowguid43 as rowguid, @generation43 as generation, @lineage43 as lineage, @colv43 as colv union all
    select @rowguid44 as rowguid, @generation44 as generation, @lineage44 as lineage, @colv44 as colv

    ) as rows
    where rows.rowguid is not NULL 

    select @rows_inserted_into_contents = @@rowcount, @error = @@error
    if @error<>0
    begin
        set @errcode=3
        goto Failure
    end

    if (@rows_inserted_into_contents <> @rows_tobe_inserted)
    begin
        raiserror(20693, 16, -1, 'member2')
        set @errcode=4
        goto Failure
    end

    insert into [dbo].[member2] with (rowlock) (
[member_no]
, 
        [lastname]
, 
        [firstname]
, 
        [middleinitial]
, 
        [street]
, 
        [city]
, 
        [state_prov]
, 
        [country]
, 
        [mail_code]
, 
        [phone_no]
, 
        [photograph]
, 
        [issue_dt]
, 
        [expr_dt]
, 
        [region_no]
, 
        [corp_no]
, 
        [prev_balance]
, 
        [curr_balance]
, 
        [member_code]
, 
        [rowguid]
)
    select 
c1
, 
        c2
, 
        c3
, 
        c4
, 
        c5
, 
        c6
, 
        c7
, 
        c8
, 
        c9
, 
        c10
, 
        c11
, 
        c12
, 
        c13
, 
        c14
, 
        c15
, 
        c16
, 
        c17
, 
        c18
, 
        rowguid

    from (

    select @p1 as c1, @p2 as c2, @p3 as c3, @p4 as c4, @p5 as c5, @p6 as c6, @p7 as c7, @p8 as c8, @p9 as c9, 
        @p10 as c10, @p11 as c11, @p12 as c12, @p13 as c13, @p14 as c14, @p15 as c15, @p16 as c16, @p17 as c17, @p18 as c18, @p19 as rowguid union all
    select @p20 as c1, @p21 as c2, @p22 as c3, @p23 as c4, @p24 as c5, @p25 as c6, @p26 as c7, @p27 as c8, @p28 as c9, 
        @p29 as c10, @p30 as c11, @p31 as c12, @p32 as c13, @p33 as c14, @p34 as c15, @p35 as c16, @p36 as c17, @p37 as c18, @p38 as rowguid union all
    select @p39 as c1, @p40 as c2, @p41 as c3, @p42 as c4, @p43 as c5, @p44 as c6, @p45 as c7, @p46 as c8, @p47 as c9, 
        @p48 as c10, @p49 as c11, @p50 as c12, @p51 as c13, @p52 as c14, @p53 as c15, @p54 as c16, @p55 as c17, @p56 as c18, @p57 as rowguid union all
    select @p58 as c1, @p59 as c2, @p60 as c3, @p61 as c4, @p62 as c5, @p63 as c6, @p64 as c7, @p65 as c8, @p66 as c9, 
        @p67 as c10, @p68 as c11, @p69 as c12, @p70 as c13, @p71 as c14, @p72 as c15, @p73 as c16, @p74 as c17, @p75 as c18, @p76 as rowguid union all
    select @p77 as c1, @p78 as c2, @p79 as c3, @p80 as c4, @p81 as c5, @p82 as c6, @p83 as c7, @p84 as c8, @p85 as c9, 
        @p86 as c10, @p87 as c11, @p88 as c12, @p89 as c13, @p90 as c14, @p91 as c15, @p92 as c16, @p93 as c17, @p94 as c18, @p95 as rowguid union all
    select @p96 as c1, @p97 as c2, @p98 as c3, @p99 as c4, @p100 as c5, @p101 as c6, @p102 as c7, @p103 as c8, @p104 as c9, 
        @p105 as c10, @p106 as c11, @p107 as c12, @p108 as c13, @p109 as c14, @p110 as c15, @p111 as c16, @p112 as c17, @p113 as c18, @p114 as rowguid union all
    select @p115 as c1, @p116 as c2, @p117 as c3, @p118 as c4, @p119 as c5, @p120 as c6, @p121 as c7, @p122 as c8, @p123 as c9, 
        @p124 as c10, @p125 as c11, @p126 as c12, @p127 as c13, @p128 as c14, @p129 as c15, @p130 as c16, @p131 as c17, @p132 as c18, @p133 as rowguid union all
    select @p134 as c1, @p135 as c2, @p136 as c3, @p137 as c4, @p138 as c5, @p139 as c6, @p140 as c7, @p141 as c8, @p142 as c9, 
        @p143 as c10, @p144 as c11, @p145 as c12, @p146 as c13, @p147 as c14, @p148 as c15, @p149 as c16, @p150 as c17, @p151 as c18, @p152 as rowguid union all
    select @p153 as c1, @p154 as c2, @p155 as c3, @p156 as c4, @p157 as c5, @p158 as c6, @p159 as c7, @p160 as c8, @p161 as c9, 
        @p162 as c10, @p163 as c11, @p164 as c12, @p165 as c13, @p166 as c14, @p167 as c15, @p168 as c16, @p169 as c17, @p170 as c18, @p171 as rowguid union all
    select @p172 as c1, @p173 as c2, @p174 as c3, @p175 as c4, @p176 as c5, @p177 as c6, @p178 as c7, @p179 as c8, @p180 as c9, 
        @p181 as c10, @p182 as c11, @p183 as c12, @p184 as c13, @p185 as c14, @p186 as c15, @p187 as c16, @p188 as c17, @p189 as c18, @p190 as rowguid union all
    select @p191 as c1, @p192 as c2, @p193 as c3, @p194 as c4, @p195 as c5, @p196 as c6, @p197 as c7, @p198 as c8, @p199 as c9, 
        @p200 as c10, @p201 as c11, @p202 as c12, @p203 as c13, @p204 as c14, @p205 as c15, @p206 as c16, @p207 as c17, @p208 as c18, @p209 as rowguid union all
    select @p210 as c1, @p211 as c2, @p212 as c3, @p213 as c4, @p214 as c5, @p215 as c6, @p216 as c7, @p217 as c8, @p218 as c9, 
        @p219 as c10, @p220 as c11, @p221 as c12, @p222 as c13, @p223 as c14, @p224 as c15, @p225 as c16, @p226 as c17, @p227 as c18, @p228 as rowguid union all
    select @p229 as c1, @p230 as c2, @p231 as c3, @p232 as c4, @p233 as c5, @p234 as c6, @p235 as c7, @p236 as c8, @p237 as c9, 
        @p238 as c10, @p239 as c11, @p240 as c12, @p241 as c13, @p242 as c14, @p243 as c15, @p244 as c16, @p245 as c17, @p246 as c18, @p247 as rowguid union all
    select @p248 as c1, @p249 as c2, @p250 as c3, @p251 as c4
, @p252 as c5, @p253 as c6, @p254 as c7, @p255 as c8, @p256 as c9, 
        @p257 as c10, @p258 as c11, @p259 as c12, @p260 as c13, @p261 as c14, @p262 as c15, @p263 as c16, @p264 as c17, @p265 as c18, @p266 as rowguid union all
    select @p267 as c1, @p268 as c2, @p269 as c3, @p270 as c4, @p271 as c5, @p272 as c6, @p273 as c7, @p274 as c8, @p275 as c9, 
        @p276 as c10, @p277 as c11, @p278 as c12, @p279 as c13, @p280 as c14, @p281 as c15, @p282 as c16, @p283 as c17, @p284 as c18, @p285 as rowguid union all
    select @p286 as c1, @p287 as c2, @p288 as c3, @p289 as c4, @p290 as c5, @p291 as c6, @p292 as c7, @p293 as c8, @p294 as c9, 
        @p295 as c10, @p296 as c11, @p297 as c12, @p298 as c13, @p299 as c14, @p300 as c15, @p301 as c16, @p302 as c17, @p303 as c18, @p304 as rowguid union all
    select @p305 as c1, @p306 as c2, @p307 as c3, @p308 as c4, @p309 as c5, @p310 as c6, @p311 as c7, @p312 as c8, @p313 as c9, 
        @p314 as c10, @p315 as c11, @p316 as c12, @p317 as c13, @p318 as c14, @p319 as c15, @p320 as c16, @p321 as c17, @p322 as c18, @p323 as rowguid union all
    select @p324 as c1, @p325 as c2, @p326 as c3, @p327 as c4, @p328 as c5, @p329 as c6, @p330 as c7, @p331 as c8, @p332 as c9, 
        @p333 as c10, @p334 as c11, @p335 as c12, @p336 as c13, @p337 as c14, @p338 as c15, @p339 as c16, @p340 as c17, @p341 as c18, @p342 as rowguid union all
    select @p343 as c1, @p344 as c2, @p345 as c3, @p346 as c4, @p347 as c5, @p348 as c6, @p349 as c7, @p350 as c8, @p351 as c9, 
        @p352 as c10, @p353 as c11, @p354 as c12, @p355 as c13, @p356 as c14, @p357 as c15, @p358 as c16, @p359 as c17, @p360 as c18, @p361 as rowguid union all
    select @p362 as c1, @p363 as c2, @p364 as c3, @p365 as c4, @p366 as c5, @p367 as c6, @p368 as c7, @p369 as c8, @p370 as c9, 
        @p371 as c10, @p372 as c11, @p373 as c12, @p374 as c13, @p375 as c14, @p376 as c15, @p377 as c16, @p378 as c17, @p379 as c18, @p380 as rowguid union all
    select @p381 as c1, @p382 as c2, @p383 as c3, @p384 as c4, @p385 as c5, @p386 as c6, @p387 as c7, @p388 as c8, @p389 as c9, 
        @p390 as c10, @p391 as c11, @p392 as c12, @p393 as c13, @p394 as c14, @p395 as c15, @p396 as c16, @p397 as c17, @p398 as c18, @p399 as rowguid union all
    select @p400 as c1, @p401 as c2, @p402 as c3, @p403 as c4, @p404 as c5, @p405 as c6, @p406 as c7, @p407 as c8, @p408 as c9, 
        @p409 as c10, @p410 as c11, @p411 as c12, @p412 as c13, @p413 as c14, @p414 as c15, @p415 as c16, @p416 as c17, @p417 as c18, @p418 as rowguid union all
    select @p419 as c1, @p420 as c2, @p421 as c3, @p422 as c4, @p423 as c5, @p424 as c6, @p425 as c7, @p426 as c8, @p427 as c9, 
        @p428 as c10, @p429 as c11, @p430 as c12, @p431 as c13, @p432 as c14, @p433 as c15, @p434 as c16, @p435 as c17, @p436 as c18, @p437 as rowguid union all
    select @p438 as c1, @p439 as c2, @p440 as c3, @p441 as c4, @p442 as c5, @p443 as c6, @p444 as c7, @p445 as c8, @p446 as c9, 
        @p447 as c10, @p448 as c11, @p449 as c12, @p450 as c13, @p451 as c14, @p452 as c15, @p453 as c16, @p454 as c17, @p455 as c18, @p456 as rowguid union all
    select @p457 as c1, @p458 as c2, @p459 as c3, @p460 as c4, @p461 as c5, @p462 as c6, @p463 as c7, @p464 as c8, @p465 as c9, 
        @p466 as c10, @p467 as c11, @p468 as c12, @p469 as c13, @p470 as c14, @p471 as c15, @p472 as c16, @p473 as c17, @p474 as c18, @p475 as rowguid union all
    select @p476 as c1, @p477 as c2, @p478 as c3, @p479 as c4, @p480 as c5, @p481 as c6, @p482 as c7, @p483 as c8, @p484 as c9, 
        @p485 as c10, @p486 as c11, @p487 as c12, @p488 as c13, @p489 as c14, @p490 as c15, @p491 as c16, @p492 as c17, @p493 as c18, @p494 as rowguid union all
    select @p495 as c1
, @p496 as c2, @p497 as c3, @p498 as c4, @p499 as c5, @p500 as c6, @p501 as c7, @p502 as c8, @p503 as c9, 
        @p504 as c10, @p505 as c11, @p506 as c12, @p507 as c13, @p508 as c14, @p509 as c15, @p510 as c16, @p511 as c17, @p512 as c18, @p513 as rowguid union all
    select @p514 as c1, @p515 as c2, @p516 as c3, @p517 as c4, @p518 as c5, @p519 as c6, @p520 as c7, @p521 as c8, @p522 as c9, 
        @p523 as c10, @p524 as c11, @p525 as c12, @p526 as c13, @p527 as c14, @p528 as c15, @p529 as c16, @p530 as c17, @p531 as c18, @p532 as rowguid union all
    select @p533 as c1, @p534 as c2, @p535 as c3, @p536 as c4, @p537 as c5, @p538 as c6, @p539 as c7, @p540 as c8, @p541 as c9, 
        @p542 as c10, @p543 as c11, @p544 as c12, @p545 as c13, @p546 as c14, @p547 as c15, @p548 as c16, @p549 as c17, @p550 as c18, @p551 as rowguid union all
    select @p552 as c1, @p553 as c2, @p554 as c3, @p555 as c4, @p556 as c5, @p557 as c6, @p558 as c7, @p559 as c8, @p560 as c9, 
        @p561 as c10, @p562 as c11, @p563 as c12, @p564 as c13, @p565 as c14, @p566 as c15, @p567 as c16, @p568 as c17, @p569 as c18, @p570 as rowguid union all
    select @p571 as c1, @p572 as c2, @p573 as c3, @p574 as c4, @p575 as c5, @p576 as c6, @p577 as c7, @p578 as c8, @p579 as c9, 
        @p580 as c10, @p581 as c11, @p582 as c12, @p583 as c13, @p584 as c14, @p585 as c15, @p586 as c16, @p587 as c17, @p588 as c18, @p589 as rowguid union all
    select @p590 as c1, @p591 as c2, @p592 as c3, @p593 as c4, @p594 as c5, @p595 as c6, @p596 as c7, @p597 as c8, @p598 as c9, 
        @p599 as c10, @p600 as c11, @p601 as c12, @p602 as c13, @p603 as c14, @p604 as c15, @p605 as c16, @p606 as c17, @p607 as c18, @p608 as rowguid union all
    select @p609 as c1, @p610 as c2, @p611 as c3, @p612 as c4, @p613 as c5, @p614 as c6, @p615 as c7, @p616 as c8, @p617 as c9, 
        @p618 as c10, @p619 as c11, @p620 as c12, @p621 as c13, @p622 as c14, @p623 as c15, @p624 as c16, @p625 as c17, @p626 as c18, @p627 as rowguid union all
    select @p628 as c1, @p629 as c2, @p630 as c3, @p631 as c4, @p632 as c5, @p633 as c6, @p634 as c7, @p635 as c8, @p636 as c9, 
        @p637 as c10, @p638 as c11, @p639 as c12, @p640 as c13, @p641 as c14, @p642 as c15, @p643 as c16, @p644 as c17, @p645 as c18, @p646 as rowguid union all
    select @p647 as c1, @p648 as c2, @p649 as c3, @p650 as c4, @p651 as c5, @p652 as c6, @p653 as c7, @p654 as c8, @p655 as c9, 
        @p656 as c10, @p657 as c11, @p658 as c12, @p659 as c13, @p660 as c14, @p661 as c15, @p662 as c16, @p663 as c17, @p664 as c18, @p665 as rowguid union all
    select @p666 as c1, @p667 as c2, @p668 as c3, @p669 as c4, @p670 as c5, @p671 as c6, @p672 as c7, @p673 as c8, @p674 as c9, 
        @p675 as c10, @p676 as c11, @p677 as c12, @p678 as c13, @p679 as c14, @p680 as c15, @p681 as c16, @p682 as c17, @p683 as c18, @p684 as rowguid union all
    select @p685 as c1, @p686 as c2, @p687 as c3, @p688 as c4, @p689 as c5, @p690 as c6, @p691 as c7, @p692 as c8, @p693 as c9, 
        @p694 as c10, @p695 as c11, @p696 as c12, @p697 as c13, @p698 as c14, @p699 as c15, @p700 as c16, @p701 as c17, @p702 as c18, @p703 as rowguid union all
    select @p704 as c1, @p705 as c2, @p706 as c3, @p707 as c4, @p708 as c5, @p709 as c6, @p710 as c7, @p711 as c8, @p712 as c9, 
        @p713 as c10, @p714 as c11, @p715 as c12, @p716 as c13, @p717 as c14, @p718 as c15, @p719 as c16, @p720 as c17, @p721 as c18, @p722 as rowguid union all
    select @p723 as c1, @p724 as c2, @p725 as c3, @p726 as c4, @p727 as c5, @p728 as c6, @p729 as c7, @p730 as c8, @p731 as c9, 
        @p732 as c10, @p733 as c11, @p734 as c12, @p735 as c13, @p736 as c14, @p737 as c15, @p738 as c16, @p739 as c17, @p740 as c18, @p741 as rowguid
 union all
    select @p742 as c1, @p743 as c2, @p744 as c3, @p745 as c4, @p746 as c5, @p747 as c6, @p748 as c7, @p749 as c8, @p750 as c9, 
        @p751 as c10, @p752 as c11, @p753 as c12, @p754 as c13, @p755 as c14, @p756 as c15, @p757 as c16, @p758 as c17, @p759 as c18, @p760 as rowguid union all
    select @p761 as c1, @p762 as c2, @p763 as c3, @p764 as c4, @p765 as c5, @p766 as c6, @p767 as c7, @p768 as c8, @p769 as c9, 
        @p770 as c10, @p771 as c11, @p772 as c12, @p773 as c13, @p774 as c14, @p775 as c15, @p776 as c16, @p777 as c17, @p778 as c18, @p779 as rowguid union all
    select @p780 as c1, @p781 as c2, @p782 as c3, @p783 as c4, @p784 as c5, @p785 as c6, @p786 as c7, @p787 as c8, @p788 as c9, 
        @p789 as c10, @p790 as c11, @p791 as c12, @p792 as c13, @p793 as c14, @p794 as c15, @p795 as c16, @p796 as c17, @p797 as c18, @p798 as rowguid union all
    select @p799 as c1, @p800 as c2, @p801 as c3, @p802 as c4, @p803 as c5, @p804 as c6, @p805 as c7, @p806 as c8, @p807 as c9, 
        @p808 as c10, @p809 as c11, @p810 as c12, @p811 as c13, @p812 as c14, @p813 as c15, @p814 as c16, @p815 as c17, @p816 as c18, @p817 as rowguid union all
    select @p818 as c1
, @p819 as c2
, @p820 as c3
, @p821 as c4
, @p822 as c5
, @p823 as c6
, @p824 as c7
, @p825 as c8
, @p826 as c9
, 
        @p827 as c10
, @p828 as c11
, @p829 as c12
, @p830 as c13
, @p831 as c14
, @p832 as c15
, @p833 as c16
, @p834 as c17
, @p835 as c18
, @p836 as rowguid

    ) as rows
    where rows.rowguid is not NULL
    select @rowcount = @@rowcount, @error = @@error

    if (@rowcount <> @rows_tobe_inserted) or (@error <> 0)
    begin
        set @errcode= 3
        goto Failure
    end


    exec @retcode = sys.sp_MSdeletemetadataactionrequest 'CEFA968C-E172-41FA-B5A5-680EAD11935A', 8260001, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39, 
        @rowguid40, 
        @rowguid41, 
        @rowguid42, 
        @rowguid43, 
        @rowguid44
    if @retcode<>0 or @@error<>0
        goto Failure
    

    commit tran
    return 1

Failure:
    rollback tran batchinsertproc
    commit tran
    return 0
end


go
create procedure dbo.[MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA_batch] (
        @rows_tobe_updated int,
        @partition_id int = null 
,
    @rowguid1 uniqueidentifier = NULL,
    @setbm1 varbinary(125) = NULL,
    @metadata_type1 tinyint = NULL,
    @lineage_old1 varbinary(311) = NULL,
    @generation1 bigint = NULL,
    @lineage_new1 varbinary(311) = NULL,
    @colv1 varbinary(1) = NULL,
    @p1 [numeric_id] = NULL,
    @p2 [shortstring] = NULL,
    @p3 [shortstring] = NULL,
    @p4 [letter] = NULL,
    @p5 [shortstring] = NULL,
    @p6 [shortstring] = NULL,
    @p7 [statecode] = NULL,
    @p8 [countrycode] = NULL,
    @p9 [mailcode] = NULL,
    @p10 [phonenumber] = NULL,
    @p11 image = NULL,
    @p12 datetime = NULL,
    @p13 datetime = NULL,
    @p14 [numeric_id] = NULL,
    @p15 [numeric_id] = NULL,
    @p16 money = NULL,
    @p17 money = NULL,
    @p18 [status_code] = NULL,
    @p19 uniqueidentifier = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @setbm2 varbinary(125) = NULL,
    @metadata_type2 tinyint = NULL,
    @lineage_old2 varbinary(311) = NULL,
    @generation2 bigint = NULL,
    @lineage_new2 varbinary(311) = NULL,
    @colv2 varbinary(1) = NULL,
    @p20 [numeric_id] = NULL,
    @p21 [shortstring] = NULL,
    @p22 [shortstring] = NULL,
    @p23 [letter] = NULL,
    @p24 [shortstring] = NULL,
    @p25 [shortstring] = NULL,
    @p26 [statecode] = NULL,
    @p27 [countrycode] = NULL,
    @p28 [mailcode] = NULL,
    @p29 [phonenumber] = NULL,
    @p30 image = NULL,
    @p31 datetime = NULL,
    @p32 datetime = NULL,
    @p33 [numeric_id] = NULL,
    @p34 [numeric_id] = NULL,
    @p35 money = NULL,
    @p36 money = NULL,
    @p37 [status_code] = NULL,
    @p38 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @setbm3 varbinary(125) = NULL,
    @metadata_type3 tinyint = NULL,
    @lineage_old3 varbinary(311) = NULL,
    @generation3 bigint = NULL,
    @lineage_new3 varbinary(311) = NULL,
    @colv3 varbinary(1) = NULL,
    @p39 [numeric_id] = NULL,
    @p40 [shortstring] = NULL,
    @p41 [shortstring] = NULL,
    @p42 [letter] = NULL,
    @p43 [shortstring] = NULL,
    @p44 [shortstring] = NULL,
    @p45 [statecode] = NULL,
    @p46 [countrycode] = NULL,
    @p47 [mailcode] = NULL,
    @p48 [phonenumber] = NULL,
    @p49 image = NULL,
    @p50 datetime = NULL,
    @p51 datetime = NULL,
    @p52 [numeric_id] = NULL,
    @p53 [numeric_id] = NULL,
    @p54 money = NULL,
    @p55 money = NULL,
    @p56 [status_code] = NULL,
    @p57 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @setbm4 varbinary(125) = NULL,
    @metadata_type4 tinyint = NULL,
    @lineage_old4 varbinary(311) = NULL,
    @generation4 bigint = NULL,
    @lineage_new4 varbinary(311) = NULL,
    @colv4 varbinary(1) = NULL,
    @p58 [numeric_id] = NULL,
    @p59 [shortstring] = NULL,
    @p60 [shortstring] = NULL,
    @p61 [letter] = NULL,
    @p62 [shortstring] = NULL,
    @p63 [shortstring] = NULL,
    @p64 [statecode] = NULL,
    @p65 [countrycode] = NULL,
    @p66 [mailcode] = NULL,
    @p67 [phonenumber] = NULL,
    @p68 image = NULL,
    @p69 datetime = NULL,
    @p70 datetime = NULL,
    @p71 [numeric_id] = NULL,
    @p72 [numeric_id] = NULL,
    @p73 money = NULL,
    @p74 money = NULL,
    @p75 [status_code] = NULL,
    @p76 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @setbm5 varbinary(125) = NULL,
    @metadata_type5 tinyint = NULL,
    @lineage_old5 varbinary(311) = NULL,
    @generation5 bigint = NULL,
    @lineage_new5 varbinary(311) = NULL,
    @colv5 varbinary(1) = NULL,
    @p77 [numeric_id] = NULL
,
    @p78 [shortstring] = NULL,
    @p79 [shortstring] = NULL,
    @p80 [letter] = NULL,
    @p81 [shortstring] = NULL,
    @p82 [shortstring] = NULL,
    @p83 [statecode] = NULL,
    @p84 [countrycode] = NULL,
    @p85 [mailcode] = NULL,
    @p86 [phonenumber] = NULL,
    @p87 image = NULL,
    @p88 datetime = NULL,
    @p89 datetime = NULL,
    @p90 [numeric_id] = NULL,
    @p91 [numeric_id] = NULL,
    @p92 money = NULL,
    @p93 money = NULL,
    @p94 [status_code] = NULL,
    @p95 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @setbm6 varbinary(125) = NULL,
    @metadata_type6 tinyint = NULL,
    @lineage_old6 varbinary(311) = NULL,
    @generation6 bigint = NULL,
    @lineage_new6 varbinary(311) = NULL,
    @colv6 varbinary(1) = NULL,
    @p96 [numeric_id] = NULL,
    @p97 [shortstring] = NULL,
    @p98 [shortstring] = NULL,
    @p99 [letter] = NULL,
    @p100 [shortstring] = NULL,
    @p101 [shortstring] = NULL,
    @p102 [statecode] = NULL,
    @p103 [countrycode] = NULL,
    @p104 [mailcode] = NULL,
    @p105 [phonenumber] = NULL,
    @p106 image = NULL,
    @p107 datetime = NULL,
    @p108 datetime = NULL,
    @p109 [numeric_id] = NULL,
    @p110 [numeric_id] = NULL,
    @p111 money = NULL,
    @p112 money = NULL,
    @p113 [status_code] = NULL,
    @p114 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @setbm7 varbinary(125) = NULL,
    @metadata_type7 tinyint = NULL,
    @lineage_old7 varbinary(311) = NULL,
    @generation7 bigint = NULL,
    @lineage_new7 varbinary(311) = NULL,
    @colv7 varbinary(1) = NULL,
    @p115 [numeric_id] = NULL,
    @p116 [shortstring] = NULL,
    @p117 [shortstring] = NULL,
    @p118 [letter] = NULL,
    @p119 [shortstring] = NULL,
    @p120 [shortstring] = NULL,
    @p121 [statecode] = NULL,
    @p122 [countrycode] = NULL,
    @p123 [mailcode] = NULL,
    @p124 [phonenumber] = NULL,
    @p125 image = NULL,
    @p126 datetime = NULL,
    @p127 datetime = NULL,
    @p128 [numeric_id] = NULL,
    @p129 [numeric_id] = NULL,
    @p130 money = NULL,
    @p131 money = NULL,
    @p132 [status_code] = NULL,
    @p133 uniqueidentifier = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @setbm8 varbinary(125) = NULL,
    @metadata_type8 tinyint = NULL,
    @lineage_old8 varbinary(311) = NULL,
    @generation8 bigint = NULL,
    @lineage_new8 varbinary(311) = NULL,
    @colv8 varbinary(1) = NULL,
    @p134 [numeric_id] = NULL,
    @p135 [shortstring] = NULL,
    @p136 [shortstring] = NULL,
    @p137 [letter] = NULL,
    @p138 [shortstring] = NULL,
    @p139 [shortstring] = NULL,
    @p140 [statecode] = NULL,
    @p141 [countrycode] = NULL,
    @p142 [mailcode] = NULL,
    @p143 [phonenumber] = NULL,
    @p144 image = NULL,
    @p145 datetime = NULL,
    @p146 datetime = NULL,
    @p147 [numeric_id] = NULL,
    @p148 [numeric_id] = NULL,
    @p149 money = NULL,
    @p150 money = NULL,
    @p151 [status_code] = NULL,
    @p152 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @setbm9 varbinary(125) = NULL,
    @metadata_type9 tinyint = NULL,
    @lineage_old9 varbinary(311) = NULL,
    @generation9 bigint = NULL,
    @lineage_new9 varbinary(311) = NULL,
    @colv9 varbinary(1) = NULL,
    @p153 [numeric_id] = NULL,
    @p154 [shortstring] = NULL,
    @p155 [shortstring] = NULL,
    @p156 [letter] = NULL,
    @p157 [shortstring] = NULL,
    @p158 [shortstring] = NULL
,
    @p159 [statecode] = NULL,
    @p160 [countrycode] = NULL,
    @p161 [mailcode] = NULL,
    @p162 [phonenumber] = NULL,
    @p163 image = NULL,
    @p164 datetime = NULL,
    @p165 datetime = NULL,
    @p166 [numeric_id] = NULL,
    @p167 [numeric_id] = NULL,
    @p168 money = NULL,
    @p169 money = NULL,
    @p170 [status_code] = NULL,
    @p171 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @setbm10 varbinary(125) = NULL,
    @metadata_type10 tinyint = NULL,
    @lineage_old10 varbinary(311) = NULL,
    @generation10 bigint = NULL,
    @lineage_new10 varbinary(311) = NULL,
    @colv10 varbinary(1) = NULL,
    @p172 [numeric_id] = NULL,
    @p173 [shortstring] = NULL,
    @p174 [shortstring] = NULL,
    @p175 [letter] = NULL,
    @p176 [shortstring] = NULL,
    @p177 [shortstring] = NULL,
    @p178 [statecode] = NULL,
    @p179 [countrycode] = NULL,
    @p180 [mailcode] = NULL,
    @p181 [phonenumber] = NULL,
    @p182 image = NULL,
    @p183 datetime = NULL,
    @p184 datetime = NULL,
    @p185 [numeric_id] = NULL,
    @p186 [numeric_id] = NULL,
    @p187 money = NULL,
    @p188 money = NULL,
    @p189 [status_code] = NULL,
    @p190 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @setbm11 varbinary(125) = NULL,
    @metadata_type11 tinyint = NULL,
    @lineage_old11 varbinary(311) = NULL,
    @generation11 bigint = NULL,
    @lineage_new11 varbinary(311) = NULL,
    @colv11 varbinary(1) = NULL,
    @p191 [numeric_id] = NULL,
    @p192 [shortstring] = NULL,
    @p193 [shortstring] = NULL,
    @p194 [letter] = NULL,
    @p195 [shortstring] = NULL,
    @p196 [shortstring] = NULL,
    @p197 [statecode] = NULL,
    @p198 [countrycode] = NULL,
    @p199 [mailcode] = NULL,
    @p200 [phonenumber] = NULL,
    @p201 image = NULL,
    @p202 datetime = NULL,
    @p203 datetime = NULL,
    @p204 [numeric_id] = NULL,
    @p205 [numeric_id] = NULL,
    @p206 money = NULL,
    @p207 money = NULL,
    @p208 [status_code] = NULL,
    @p209 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @setbm12 varbinary(125) = NULL,
    @metadata_type12 tinyint = NULL,
    @lineage_old12 varbinary(311) = NULL,
    @generation12 bigint = NULL,
    @lineage_new12 varbinary(311) = NULL,
    @colv12 varbinary(1) = NULL,
    @p210 [numeric_id] = NULL,
    @p211 [shortstring] = NULL,
    @p212 [shortstring] = NULL,
    @p213 [letter] = NULL,
    @p214 [shortstring] = NULL,
    @p215 [shortstring] = NULL,
    @p216 [statecode] = NULL,
    @p217 [countrycode] = NULL,
    @p218 [mailcode] = NULL,
    @p219 [phonenumber] = NULL,
    @p220 image = NULL,
    @p221 datetime = NULL,
    @p222 datetime = NULL,
    @p223 [numeric_id] = NULL,
    @p224 [numeric_id] = NULL,
    @p225 money = NULL,
    @p226 money = NULL,
    @p227 [status_code] = NULL,
    @p228 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @setbm13 varbinary(125) = NULL,
    @metadata_type13 tinyint = NULL,
    @lineage_old13 varbinary(311) = NULL,
    @generation13 bigint = NULL,
    @lineage_new13 varbinary(311) = NULL,
    @colv13 varbinary(1) = NULL,
    @p229 [numeric_id] = NULL,
    @p230 [shortstring] = NULL,
    @p231 [shortstring] = NULL,
    @p232 [letter] = NULL,
    @p233 [shortstring] = NULL,
    @p234 [shortstring] = NULL,
    @p235 [statecode] = NULL,
    @p236 [countrycode] = NULL,
    @p237 [mailcode] = NULL
,
    @p238 [phonenumber] = NULL,
    @p239 image = NULL,
    @p240 datetime = NULL,
    @p241 datetime = NULL,
    @p242 [numeric_id] = NULL,
    @p243 [numeric_id] = NULL,
    @p244 money = NULL,
    @p245 money = NULL,
    @p246 [status_code] = NULL,
    @p247 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @setbm14 varbinary(125) = NULL,
    @metadata_type14 tinyint = NULL,
    @lineage_old14 varbinary(311) = NULL,
    @generation14 bigint = NULL,
    @lineage_new14 varbinary(311) = NULL,
    @colv14 varbinary(1) = NULL,
    @p248 [numeric_id] = NULL,
    @p249 [shortstring] = NULL,
    @p250 [shortstring] = NULL,
    @p251 [letter] = NULL,
    @p252 [shortstring] = NULL,
    @p253 [shortstring] = NULL,
    @p254 [statecode] = NULL,
    @p255 [countrycode] = NULL,
    @p256 [mailcode] = NULL,
    @p257 [phonenumber] = NULL,
    @p258 image = NULL,
    @p259 datetime = NULL,
    @p260 datetime = NULL,
    @p261 [numeric_id] = NULL,
    @p262 [numeric_id] = NULL,
    @p263 money = NULL,
    @p264 money = NULL,
    @p265 [status_code] = NULL,
    @p266 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @setbm15 varbinary(125) = NULL,
    @metadata_type15 tinyint = NULL,
    @lineage_old15 varbinary(311) = NULL,
    @generation15 bigint = NULL,
    @lineage_new15 varbinary(311) = NULL,
    @colv15 varbinary(1) = NULL,
    @p267 [numeric_id] = NULL,
    @p268 [shortstring] = NULL,
    @p269 [shortstring] = NULL,
    @p270 [letter] = NULL,
    @p271 [shortstring] = NULL,
    @p272 [shortstring] = NULL,
    @p273 [statecode] = NULL,
    @p274 [countrycode] = NULL,
    @p275 [mailcode] = NULL,
    @p276 [phonenumber] = NULL,
    @p277 image = NULL,
    @p278 datetime = NULL,
    @p279 datetime = NULL,
    @p280 [numeric_id] = NULL,
    @p281 [numeric_id] = NULL,
    @p282 money = NULL,
    @p283 money = NULL,
    @p284 [status_code] = NULL,
    @p285 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @setbm16 varbinary(125) = NULL,
    @metadata_type16 tinyint = NULL,
    @lineage_old16 varbinary(311) = NULL,
    @generation16 bigint = NULL,
    @lineage_new16 varbinary(311) = NULL,
    @colv16 varbinary(1) = NULL,
    @p286 [numeric_id] = NULL,
    @p287 [shortstring] = NULL,
    @p288 [shortstring] = NULL,
    @p289 [letter] = NULL,
    @p290 [shortstring] = NULL,
    @p291 [shortstring] = NULL,
    @p292 [statecode] = NULL,
    @p293 [countrycode] = NULL,
    @p294 [mailcode] = NULL,
    @p295 [phonenumber] = NULL,
    @p296 image = NULL,
    @p297 datetime = NULL,
    @p298 datetime = NULL,
    @p299 [numeric_id] = NULL,
    @p300 [numeric_id] = NULL,
    @p301 money = NULL,
    @p302 money = NULL,
    @p303 [status_code] = NULL,
    @p304 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @setbm17 varbinary(125) = NULL,
    @metadata_type17 tinyint = NULL,
    @lineage_old17 varbinary(311) = NULL,
    @generation17 bigint = NULL,
    @lineage_new17 varbinary(311) = NULL,
    @colv17 varbinary(1) = NULL,
    @p305 [numeric_id] = NULL,
    @p306 [shortstring] = NULL,
    @p307 [shortstring] = NULL,
    @p308 [letter] = NULL,
    @p309 [shortstring] = NULL,
    @p310 [shortstring] = NULL,
    @p311 [statecode] = NULL,
    @p312 [countrycode] = NULL,
    @p313 [mailcode] = NULL,
    @p314 [phonenumber] = NULL,
    @p315 image = NULL,
    @p316 datetime = NULL,
    @p317 datetime = NULL
,
    @p318 [numeric_id] = NULL,
    @p319 [numeric_id] = NULL,
    @p320 money = NULL,
    @p321 money = NULL,
    @p322 [status_code] = NULL,
    @p323 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @setbm18 varbinary(125) = NULL,
    @metadata_type18 tinyint = NULL,
    @lineage_old18 varbinary(311) = NULL,
    @generation18 bigint = NULL,
    @lineage_new18 varbinary(311) = NULL,
    @colv18 varbinary(1) = NULL,
    @p324 [numeric_id] = NULL,
    @p325 [shortstring] = NULL,
    @p326 [shortstring] = NULL,
    @p327 [letter] = NULL,
    @p328 [shortstring] = NULL,
    @p329 [shortstring] = NULL,
    @p330 [statecode] = NULL,
    @p331 [countrycode] = NULL,
    @p332 [mailcode] = NULL,
    @p333 [phonenumber] = NULL,
    @p334 image = NULL,
    @p335 datetime = NULL,
    @p336 datetime = NULL,
    @p337 [numeric_id] = NULL,
    @p338 [numeric_id] = NULL,
    @p339 money = NULL,
    @p340 money = NULL,
    @p341 [status_code] = NULL,
    @p342 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @setbm19 varbinary(125) = NULL,
    @metadata_type19 tinyint = NULL,
    @lineage_old19 varbinary(311) = NULL,
    @generation19 bigint = NULL,
    @lineage_new19 varbinary(311) = NULL,
    @colv19 varbinary(1) = NULL,
    @p343 [numeric_id] = NULL,
    @p344 [shortstring] = NULL,
    @p345 [shortstring] = NULL,
    @p346 [letter] = NULL,
    @p347 [shortstring] = NULL,
    @p348 [shortstring] = NULL,
    @p349 [statecode] = NULL,
    @p350 [countrycode] = NULL,
    @p351 [mailcode] = NULL,
    @p352 [phonenumber] = NULL,
    @p353 image = NULL,
    @p354 datetime = NULL,
    @p355 datetime = NULL,
    @p356 [numeric_id] = NULL,
    @p357 [numeric_id] = NULL,
    @p358 money = NULL,
    @p359 money = NULL,
    @p360 [status_code] = NULL,
    @p361 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @setbm20 varbinary(125) = NULL,
    @metadata_type20 tinyint = NULL,
    @lineage_old20 varbinary(311) = NULL,
    @generation20 bigint = NULL,
    @lineage_new20 varbinary(311) = NULL,
    @colv20 varbinary(1) = NULL,
    @p362 [numeric_id] = NULL,
    @p363 [shortstring] = NULL,
    @p364 [shortstring] = NULL,
    @p365 [letter] = NULL,
    @p366 [shortstring] = NULL,
    @p367 [shortstring] = NULL,
    @p368 [statecode] = NULL,
    @p369 [countrycode] = NULL,
    @p370 [mailcode] = NULL,
    @p371 [phonenumber] = NULL,
    @p372 image = NULL,
    @p373 datetime = NULL,
    @p374 datetime = NULL,
    @p375 [numeric_id] = NULL,
    @p376 [numeric_id] = NULL,
    @p377 money = NULL,
    @p378 money = NULL,
    @p379 [status_code] = NULL,
    @p380 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @setbm21 varbinary(125) = NULL,
    @metadata_type21 tinyint = NULL,
    @lineage_old21 varbinary(311) = NULL,
    @generation21 bigint = NULL,
    @lineage_new21 varbinary(311) = NULL,
    @colv21 varbinary(1) = NULL,
    @p381 [numeric_id] = NULL,
    @p382 [shortstring] = NULL,
    @p383 [shortstring] = NULL,
    @p384 [letter] = NULL,
    @p385 [shortstring] = NULL,
    @p386 [shortstring] = NULL,
    @p387 [statecode] = NULL,
    @p388 [countrycode] = NULL,
    @p389 [mailcode] = NULL,
    @p390 [phonenumber] = NULL,
    @p391 image = NULL,
    @p392 datetime = NULL,
    @p393 datetime = NULL,
    @p394 [numeric_id] = NULL,
    @p395 [numeric_id] = NULL,
    @p396 money = NULL
,
    @p397 money = NULL,
    @p398 [status_code] = NULL,
    @p399 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @setbm22 varbinary(125) = NULL,
    @metadata_type22 tinyint = NULL,
    @lineage_old22 varbinary(311) = NULL,
    @generation22 bigint = NULL,
    @lineage_new22 varbinary(311) = NULL,
    @colv22 varbinary(1) = NULL,
    @p400 [numeric_id] = NULL,
    @p401 [shortstring] = NULL,
    @p402 [shortstring] = NULL,
    @p403 [letter] = NULL,
    @p404 [shortstring] = NULL,
    @p405 [shortstring] = NULL,
    @p406 [statecode] = NULL,
    @p407 [countrycode] = NULL,
    @p408 [mailcode] = NULL,
    @p409 [phonenumber] = NULL,
    @p410 image = NULL,
    @p411 datetime = NULL,
    @p412 datetime = NULL,
    @p413 [numeric_id] = NULL,
    @p414 [numeric_id] = NULL,
    @p415 money = NULL,
    @p416 money = NULL,
    @p417 [status_code] = NULL,
    @p418 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @setbm23 varbinary(125) = NULL,
    @metadata_type23 tinyint = NULL,
    @lineage_old23 varbinary(311) = NULL,
    @generation23 bigint = NULL,
    @lineage_new23 varbinary(311) = NULL,
    @colv23 varbinary(1) = NULL,
    @p419 [numeric_id] = NULL,
    @p420 [shortstring] = NULL,
    @p421 [shortstring] = NULL,
    @p422 [letter] = NULL,
    @p423 [shortstring] = NULL,
    @p424 [shortstring] = NULL,
    @p425 [statecode] = NULL,
    @p426 [countrycode] = NULL,
    @p427 [mailcode] = NULL,
    @p428 [phonenumber] = NULL,
    @p429 image = NULL,
    @p430 datetime = NULL,
    @p431 datetime = NULL,
    @p432 [numeric_id] = NULL,
    @p433 [numeric_id] = NULL,
    @p434 money = NULL,
    @p435 money = NULL,
    @p436 [status_code] = NULL,
    @p437 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @setbm24 varbinary(125) = NULL,
    @metadata_type24 tinyint = NULL,
    @lineage_old24 varbinary(311) = NULL,
    @generation24 bigint = NULL,
    @lineage_new24 varbinary(311) = NULL,
    @colv24 varbinary(1) = NULL,
    @p438 [numeric_id] = NULL,
    @p439 [shortstring] = NULL,
    @p440 [shortstring] = NULL,
    @p441 [letter] = NULL,
    @p442 [shortstring] = NULL,
    @p443 [shortstring] = NULL,
    @p444 [statecode] = NULL,
    @p445 [countrycode] = NULL,
    @p446 [mailcode] = NULL,
    @p447 [phonenumber] = NULL,
    @p448 image = NULL,
    @p449 datetime = NULL,
    @p450 datetime = NULL,
    @p451 [numeric_id] = NULL,
    @p452 [numeric_id] = NULL,
    @p453 money = NULL,
    @p454 money = NULL,
    @p455 [status_code] = NULL,
    @p456 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @setbm25 varbinary(125) = NULL,
    @metadata_type25 tinyint = NULL,
    @lineage_old25 varbinary(311) = NULL,
    @generation25 bigint = NULL,
    @lineage_new25 varbinary(311) = NULL,
    @colv25 varbinary(1) = NULL,
    @p457 [numeric_id] = NULL,
    @p458 [shortstring] = NULL,
    @p459 [shortstring] = NULL,
    @p460 [letter] = NULL,
    @p461 [shortstring] = NULL,
    @p462 [shortstring] = NULL,
    @p463 [statecode] = NULL,
    @p464 [countrycode] = NULL,
    @p465 [mailcode] = NULL,
    @p466 [phonenumber] = NULL,
    @p467 image = NULL,
    @p468 datetime = NULL,
    @p469 datetime = NULL,
    @p470 [numeric_id] = NULL,
    @p471 [numeric_id] = NULL,
    @p472 money = NULL,
    @p473 money = NULL,
    @p474 [status_code] = NULL,
    @p475 uniqueidentifier = NULL
,
    @rowguid26 uniqueidentifier = NULL,
    @setbm26 varbinary(125) = NULL,
    @metadata_type26 tinyint = NULL,
    @lineage_old26 varbinary(311) = NULL,
    @generation26 bigint = NULL,
    @lineage_new26 varbinary(311) = NULL,
    @colv26 varbinary(1) = NULL,
    @p476 [numeric_id] = NULL,
    @p477 [shortstring] = NULL,
    @p478 [shortstring] = NULL,
    @p479 [letter] = NULL,
    @p480 [shortstring] = NULL,
    @p481 [shortstring] = NULL,
    @p482 [statecode] = NULL,
    @p483 [countrycode] = NULL,
    @p484 [mailcode] = NULL,
    @p485 [phonenumber] = NULL,
    @p486 image = NULL,
    @p487 datetime = NULL,
    @p488 datetime = NULL,
    @p489 [numeric_id] = NULL,
    @p490 [numeric_id] = NULL,
    @p491 money = NULL,
    @p492 money = NULL,
    @p493 [status_code] = NULL,
    @p494 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @setbm27 varbinary(125) = NULL,
    @metadata_type27 tinyint = NULL,
    @lineage_old27 varbinary(311) = NULL,
    @generation27 bigint = NULL,
    @lineage_new27 varbinary(311) = NULL,
    @colv27 varbinary(1) = NULL,
    @p495 [numeric_id] = NULL,
    @p496 [shortstring] = NULL,
    @p497 [shortstring] = NULL,
    @p498 [letter] = NULL,
    @p499 [shortstring] = NULL,
    @p500 [shortstring] = NULL,
    @p501 [statecode] = NULL,
    @p502 [countrycode] = NULL,
    @p503 [mailcode] = NULL,
    @p504 [phonenumber] = NULL,
    @p505 image = NULL,
    @p506 datetime = NULL,
    @p507 datetime = NULL,
    @p508 [numeric_id] = NULL,
    @p509 [numeric_id] = NULL,
    @p510 money = NULL,
    @p511 money = NULL,
    @p512 [status_code] = NULL,
    @p513 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @setbm28 varbinary(125) = NULL,
    @metadata_type28 tinyint = NULL,
    @lineage_old28 varbinary(311) = NULL,
    @generation28 bigint = NULL,
    @lineage_new28 varbinary(311) = NULL,
    @colv28 varbinary(1) = NULL,
    @p514 [numeric_id] = NULL,
    @p515 [shortstring] = NULL,
    @p516 [shortstring] = NULL,
    @p517 [letter] = NULL,
    @p518 [shortstring] = NULL,
    @p519 [shortstring] = NULL,
    @p520 [statecode] = NULL,
    @p521 [countrycode] = NULL,
    @p522 [mailcode] = NULL,
    @p523 [phonenumber] = NULL,
    @p524 image = NULL,
    @p525 datetime = NULL,
    @p526 datetime = NULL,
    @p527 [numeric_id] = NULL,
    @p528 [numeric_id] = NULL,
    @p529 money = NULL,
    @p530 money = NULL,
    @p531 [status_code] = NULL,
    @p532 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @setbm29 varbinary(125) = NULL,
    @metadata_type29 tinyint = NULL,
    @lineage_old29 varbinary(311) = NULL,
    @generation29 bigint = NULL,
    @lineage_new29 varbinary(311) = NULL,
    @colv29 varbinary(1) = NULL,
    @p533 [numeric_id] = NULL,
    @p534 [shortstring] = NULL,
    @p535 [shortstring] = NULL,
    @p536 [letter] = NULL,
    @p537 [shortstring] = NULL,
    @p538 [shortstring] = NULL,
    @p539 [statecode] = NULL,
    @p540 [countrycode] = NULL,
    @p541 [mailcode] = NULL,
    @p542 [phonenumber] = NULL,
    @p543 image = NULL,
    @p544 datetime = NULL,
    @p545 datetime = NULL,
    @p546 [numeric_id] = NULL,
    @p547 [numeric_id] = NULL,
    @p548 money = NULL,
    @p549 money = NULL,
    @p550 [status_code] = NULL,
    @p551 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @setbm30 varbinary(125) = NULL,
    @metadata_type30 tinyint = NULL,
    @lineage_old30 varbinary(311) = NULL,
    @generation30 bigint = NULL,
    @lineage_new30 varbinary(311) = NULL,
    @colv30 varbinary(1) = NULL,
    @p552 [numeric_id] = NULL
,
    @p553 [shortstring] = NULL,
    @p554 [shortstring] = NULL,
    @p555 [letter] = NULL,
    @p556 [shortstring] = NULL,
    @p557 [shortstring] = NULL,
    @p558 [statecode] = NULL,
    @p559 [countrycode] = NULL,
    @p560 [mailcode] = NULL,
    @p561 [phonenumber] = NULL,
    @p562 image = NULL,
    @p563 datetime = NULL,
    @p564 datetime = NULL,
    @p565 [numeric_id] = NULL,
    @p566 [numeric_id] = NULL,
    @p567 money = NULL,
    @p568 money = NULL,
    @p569 [status_code] = NULL,
    @p570 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @setbm31 varbinary(125) = NULL,
    @metadata_type31 tinyint = NULL,
    @lineage_old31 varbinary(311) = NULL,
    @generation31 bigint = NULL,
    @lineage_new31 varbinary(311) = NULL,
    @colv31 varbinary(1) = NULL,
    @p571 [numeric_id] = NULL,
    @p572 [shortstring] = NULL,
    @p573 [shortstring] = NULL,
    @p574 [letter] = NULL,
    @p575 [shortstring] = NULL,
    @p576 [shortstring] = NULL,
    @p577 [statecode] = NULL,
    @p578 [countrycode] = NULL,
    @p579 [mailcode] = NULL,
    @p580 [phonenumber] = NULL,
    @p581 image = NULL,
    @p582 datetime = NULL,
    @p583 datetime = NULL,
    @p584 [numeric_id] = NULL,
    @p585 [numeric_id] = NULL,
    @p586 money = NULL,
    @p587 money = NULL,
    @p588 [status_code] = NULL,
    @p589 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @setbm32 varbinary(125) = NULL,
    @metadata_type32 tinyint = NULL,
    @lineage_old32 varbinary(311) = NULL,
    @generation32 bigint = NULL,
    @lineage_new32 varbinary(311) = NULL,
    @colv32 varbinary(1) = NULL,
    @p590 [numeric_id] = NULL,
    @p591 [shortstring] = NULL,
    @p592 [shortstring] = NULL,
    @p593 [letter] = NULL,
    @p594 [shortstring] = NULL,
    @p595 [shortstring] = NULL,
    @p596 [statecode] = NULL,
    @p597 [countrycode] = NULL,
    @p598 [mailcode] = NULL,
    @p599 [phonenumber] = NULL,
    @p600 image = NULL,
    @p601 datetime = NULL,
    @p602 datetime = NULL,
    @p603 [numeric_id] = NULL,
    @p604 [numeric_id] = NULL,
    @p605 money = NULL,
    @p606 money = NULL,
    @p607 [status_code] = NULL,
    @p608 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @setbm33 varbinary(125) = NULL,
    @metadata_type33 tinyint = NULL,
    @lineage_old33 varbinary(311) = NULL,
    @generation33 bigint = NULL,
    @lineage_new33 varbinary(311) = NULL,
    @colv33 varbinary(1) = NULL,
    @p609 [numeric_id] = NULL,
    @p610 [shortstring] = NULL,
    @p611 [shortstring] = NULL,
    @p612 [letter] = NULL,
    @p613 [shortstring] = NULL,
    @p614 [shortstring] = NULL,
    @p615 [statecode] = NULL,
    @p616 [countrycode] = NULL,
    @p617 [mailcode] = NULL,
    @p618 [phonenumber] = NULL,
    @p619 image = NULL,
    @p620 datetime = NULL,
    @p621 datetime = NULL,
    @p622 [numeric_id] = NULL,
    @p623 [numeric_id] = NULL,
    @p624 money = NULL,
    @p625 money = NULL,
    @p626 [status_code] = NULL,
    @p627 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @setbm34 varbinary(125) = NULL,
    @metadata_type34 tinyint = NULL,
    @lineage_old34 varbinary(311) = NULL,
    @generation34 bigint = NULL,
    @lineage_new34 varbinary(311) = NULL,
    @colv34 varbinary(1) = NULL,
    @p628 [numeric_id] = NULL,
    @p629 [shortstring] = NULL,
    @p630 [shortstring] = NULL,
    @p631 [letter] = NULL
,
    @p632 [shortstring] = NULL,
    @p633 [shortstring] = NULL,
    @p634 [statecode] = NULL,
    @p635 [countrycode] = NULL,
    @p636 [mailcode] = NULL,
    @p637 [phonenumber] = NULL,
    @p638 image = NULL,
    @p639 datetime = NULL,
    @p640 datetime = NULL,
    @p641 [numeric_id] = NULL,
    @p642 [numeric_id] = NULL,
    @p643 money = NULL,
    @p644 money = NULL,
    @p645 [status_code] = NULL,
    @p646 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @setbm35 varbinary(125) = NULL,
    @metadata_type35 tinyint = NULL,
    @lineage_old35 varbinary(311) = NULL,
    @generation35 bigint = NULL,
    @lineage_new35 varbinary(311) = NULL,
    @colv35 varbinary(1) = NULL,
    @p647 [numeric_id] = NULL,
    @p648 [shortstring] = NULL,
    @p649 [shortstring] = NULL,
    @p650 [letter] = NULL,
    @p651 [shortstring] = NULL,
    @p652 [shortstring] = NULL,
    @p653 [statecode] = NULL,
    @p654 [countrycode] = NULL,
    @p655 [mailcode] = NULL,
    @p656 [phonenumber] = NULL,
    @p657 image = NULL,
    @p658 datetime = NULL,
    @p659 datetime = NULL,
    @p660 [numeric_id] = NULL,
    @p661 [numeric_id] = NULL,
    @p662 money = NULL,
    @p663 money = NULL,
    @p664 [status_code] = NULL,
    @p665 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @setbm36 varbinary(125) = NULL,
    @metadata_type36 tinyint = NULL,
    @lineage_old36 varbinary(311) = NULL,
    @generation36 bigint = NULL,
    @lineage_new36 varbinary(311) = NULL,
    @colv36 varbinary(1) = NULL,
    @p666 [numeric_id] = NULL,
    @p667 [shortstring] = NULL,
    @p668 [shortstring] = NULL,
    @p669 [letter] = NULL,
    @p670 [shortstring] = NULL,
    @p671 [shortstring] = NULL,
    @p672 [statecode] = NULL,
    @p673 [countrycode] = NULL,
    @p674 [mailcode] = NULL,
    @p675 [phonenumber] = NULL,
    @p676 image = NULL,
    @p677 datetime = NULL,
    @p678 datetime = NULL,
    @p679 [numeric_id] = NULL,
    @p680 [numeric_id] = NULL,
    @p681 money = NULL,
    @p682 money = NULL,
    @p683 [status_code] = NULL,
    @p684 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @setbm37 varbinary(125) = NULL,
    @metadata_type37 tinyint = NULL,
    @lineage_old37 varbinary(311) = NULL,
    @generation37 bigint = NULL,
    @lineage_new37 varbinary(311) = NULL,
    @colv37 varbinary(1) = NULL,
    @p685 [numeric_id] = NULL,
    @p686 [shortstring] = NULL,
    @p687 [shortstring] = NULL,
    @p688 [letter] = NULL,
    @p689 [shortstring] = NULL,
    @p690 [shortstring] = NULL,
    @p691 [statecode] = NULL,
    @p692 [countrycode] = NULL,
    @p693 [mailcode] = NULL,
    @p694 [phonenumber] = NULL,
    @p695 image = NULL,
    @p696 datetime = NULL,
    @p697 datetime = NULL,
    @p698 [numeric_id] = NULL,
    @p699 [numeric_id] = NULL,
    @p700 money = NULL,
    @p701 money = NULL,
    @p702 [status_code] = NULL,
    @p703 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @setbm38 varbinary(125) = NULL,
    @metadata_type38 tinyint = NULL,
    @lineage_old38 varbinary(311) = NULL,
    @generation38 bigint = NULL,
    @lineage_new38 varbinary(311) = NULL,
    @colv38 varbinary(1) = NULL,
    @p704 [numeric_id] = NULL,
    @p705 [shortstring] = NULL,
    @p706 [shortstring] = NULL,
    @p707 [letter] = NULL,
    @p708 [shortstring] = NULL,
    @p709 [shortstring] = NULL,
    @p710 [statecode] = NULL
,
    @p711 [countrycode] = NULL,
    @p712 [mailcode] = NULL,
    @p713 [phonenumber] = NULL,
    @p714 image = NULL,
    @p715 datetime = NULL,
    @p716 datetime = NULL,
    @p717 [numeric_id] = NULL,
    @p718 [numeric_id] = NULL,
    @p719 money = NULL,
    @p720 money = NULL,
    @p721 [status_code] = NULL,
    @p722 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @setbm39 varbinary(125) = NULL,
    @metadata_type39 tinyint = NULL,
    @lineage_old39 varbinary(311) = NULL,
    @generation39 bigint = NULL,
    @lineage_new39 varbinary(311) = NULL,
    @colv39 varbinary(1) = NULL,
    @p723 [numeric_id] = NULL
,
    @p724 [shortstring] = NULL
,
    @p725 [shortstring] = NULL
,
    @p726 [letter] = NULL
,
    @p727 [shortstring] = NULL
,
    @p728 [shortstring] = NULL
,
    @p729 [statecode] = NULL
,
    @p730 [countrycode] = NULL
,
    @p731 [mailcode] = NULL
,
    @p732 [phonenumber] = NULL
,
    @p733 image = NULL
,
    @p734 datetime = NULL
,
    @p735 datetime = NULL
,
    @p736 [numeric_id] = NULL
,
    @p737 [numeric_id] = NULL
,
    @p738 money = NULL
,
    @p739 money = NULL
,
    @p740 [status_code] = NULL
,
    @p741 uniqueidentifier = NULL

) as
begin
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @publication_number smallint
    declare @filtering_column_updated bit
    declare @rows_updated int
    declare @cont_rows_updated int
    declare @rows_in_syncview int
    
    set nocount on
    
    set @errcode= 0
    set @publication_number = 1
    
    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    if @rows_tobe_updated is NULL or @rows_tobe_updated <=0
        return 0

    select @filtering_column_updated = 0
    select @rows_updated = 0
    select @cont_rows_updated = 0 

    begin tran
    save tran batchupdateproc 

    update [dbo].[member2] with (rowlock)
    set 

        [member_no] = case when rows.c1 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 1) <> 0 then rows.c1 else t.[member_no] end) else rows.c1 end 
,
        [lastname] = case when rows.c2 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 2) <> 0 then rows.c2 else t.[lastname] end) else rows.c2 end 
,
        [firstname] = case when rows.c3 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 3) <> 0 then rows.c3 else t.[firstname] end) else rows.c3 end 
,
        [middleinitial] = case when rows.c4 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 4) <> 0 then rows.c4 else t.[middleinitial] end) else rows.c4 end 
,
        [street] = case when rows.c5 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 5) <> 0 then rows.c5 else t.[street] end) else rows.c5 end 
,
        [city] = case when rows.c6 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 6) <> 0 then rows.c6 else t.[city] end) else rows.c6 end 
,
        [state_prov] = case when rows.c7 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 7) <> 0 then rows.c7 else t.[state_prov] end) else rows.c7 end 
,
        [country] = case when rows.c8 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 8) <> 0 then rows.c8 else t.[country] end) else rows.c8 end 
,
        [mail_code] = case when rows.c9 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 9) <> 0 then rows.c9 else t.[mail_code] end) else rows.c9 end 
,
        [phone_no] = case when rows.c10 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 10) <> 0 then rows.c10 else t.[phone_no] end) else rows.c10 end 
,
        [photograph] = case when rows.c11 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 11) <> 0 then rows.c11 else t.[photograph] end) else rows.c11 end 
,
        [issue_dt] = case when rows.c12 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 12) <> 0 then rows.c12 else t.[issue_dt] end) else rows.c12 end 
,
        [expr_dt] = case when rows.c13 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 13) <> 0 then rows.c13 else t.[expr_dt] end) else rows.c13 end 
,
        [region_no] = case when rows.c14 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 14) <> 0 then rows.c14 else t.[region_no] end) else rows.c14 end 
,
        [corp_no] = case when rows.c15 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 15) <> 0 then rows.c15 else t.[corp_no] end) else rows.c15 end 
,
        [prev_balance] = case when rows.c16 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 16) <> 0 then rows.c16 else t.[prev_balance] end) else rows.c16 end 
,
        [curr_balance] = case when rows.c17 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 17) <> 0 then rows.c17 else t.[curr_balance] end) else rows.c17 end 
,
        [member_code] = case when rows.c18 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 18) <> 0 then rows.c18 else t.[member_code] end) else rows.c18 end 

    from (

    select @rowguid1 as rowguid, @setbm1 as setbm, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @p1 as c1, @p2 as c2, @p3 as c3, @p4 as c4, @p5 as c5, @p6 as c6, @p7 as c7, @p8 as c8, @p9 as c9, 
            @p10 as c10, @p11 as c11, @p12 as c12, @p13 as c13, @p14 as c14, @p15 as c15, @p16 as c16, @p17 as c17, @p18 as c18 union all
    select @rowguid2 as rowguid, @setbm2 as setbm, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @p20 as c1, @p21 as c2, @p22 as c3, @p23 as c4, @p24 as c5, @p25 as c6, @p26 as c7, @p27 as c8, @p28 as c9, 
            @p29 as c10, @p30 as c11, @p31 as c12, @p32 as c13, @p33 as c14, @p34 as c15, @p35 as c16, @p36 as c17, @p37 as c18 union all
    select @rowguid3 as rowguid, @setbm3 as setbm, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @p39 as c1, @p40 as c2, @p41 as c3, @p42 as c4, @p43 as c5, @p44 as c6, @p45 as c7, @p46 as c8, @p47 as c9, 
            @p48 as c10, @p49 as c11, @p50 as c12, @p51 as c13, @p52 as c14, @p53 as c15, @p54 as c16, @p55 as c17, @p56 as c18 union all
    select @rowguid4 as rowguid, @setbm4 as setbm, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @p58 as c1, @p59 as c2, @p60 as c3, @p61 as c4, @p62 as c5, @p63 as c6, @p64 as c7, @p65 as c8, @p66 as c9, 
            @p67 as c10, @p68 as c11, @p69 as c12, @p70 as c13, @p71 as c14, @p72 as c15, @p73 as c16, @p74 as c17, @p75 as c18 union all
    select @rowguid5 as rowguid, @setbm5 as setbm, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @p77 as c1, @p78 as c2, @p79 as c3, @p80 as c4, @p81 as c5, @p82 as c6, @p83 as c7, @p84 as c8, @p85 as c9, 
            @p86 as c10, @p87 as c11, @p88 as c12, @p89 as c13, @p90 as c14, @p91 as c15, @p92 as c16, @p93 as c17, @p94 as c18 union all
    select @rowguid6 as rowguid, @setbm6 as setbm, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @p96 as c1, @p97 as c2, @p98 as c3, @p99 as c4, @p100 as c5, @p101 as c6, @p102 as c7, @p103 as c8, @p104 as c9, 
            @p105 as c10, @p106 as c11, @p107 as c12, @p108 as c13, @p109 as c14, @p110 as c15, @p111 as c16, @p112 as c17, @p113 as c18 union all
    select @rowguid7 as rowguid, @setbm7 as setbm, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @p115 as c1, @p116 as c2, @p117 as c3, @p118 as c4, @p119 as c5, @p120 as c6, @p121 as c7, @p122 as c8, @p123 as c9, 
            @p124 as c10, @p125 as c11, @p126 as c12, @p127 as c13, @p128 as c14, @p129 as c15, @p130 as c16, @p131 as c17, @p132 as c18 union all
    select @rowguid8 as rowguid, @setbm8 as setbm, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @p134 as c1, @p135 as c2, @p136 as c3, @p137 as c4, @p138 as c5, @p139 as c6, @p140 as c7, @p141 as c8, @p142 as c9, 
            @p143 as c10, @p144 as c11, @p145 as c12, @p146 as c13, @p147 as c14, @p148 as c15, @p149 as c16, @p150 as c17, @p151 as c18 union all
    select @rowguid9 as rowguid, @setbm9 as setbm, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @p153 as c1, @p154 as c2, @p155 as c3, @p156 as c4, @p157 as c5, @p158 as c6, @p159 as c7, @p160 as c8, @p161 as c9, 
            @p162 as c10, @p163 as c11, @p164 as c12, @p165 as c13, @p166 as c14, @p167 as c15, @p168 as c16, @p169 as c17, @p170 as c18 union all
    select @rowguid10 as rowguid, @setbm10 as setbm, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @p172 as c1, @p173 as c2, @p174 as c3, @p175 as c4, @p176 as c5, @p177 as c6, @p178 as c7, @p179 as c8, @p180 as c9, 
            @p181 as c10, @p182 as c11, @p183 as c12, @p184 as c13, @p185 as c14, @p186 as c15, @p187 as c16, @p188 as c17, @p189 as c18 union all
    select @rowguid11 as rowguid, @setbm11 as setbm, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @p191 as c1
, @p192 as c2, @p193 as c3, @p194 as c4, @p195 as c5, @p196 as c6, @p197 as c7, @p198 as c8, @p199 as c9, 
            @p200 as c10, @p201 as c11, @p202 as c12, @p203 as c13, @p204 as c14, @p205 as c15, @p206 as c16, @p207 as c17, @p208 as c18 union all
    select @rowguid12 as rowguid, @setbm12 as setbm, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @p210 as c1, @p211 as c2, @p212 as c3, @p213 as c4, @p214 as c5, @p215 as c6, @p216 as c7, @p217 as c8, @p218 as c9, 
            @p219 as c10, @p220 as c11, @p221 as c12, @p222 as c13, @p223 as c14, @p224 as c15, @p225 as c16, @p226 as c17, @p227 as c18 union all
    select @rowguid13 as rowguid, @setbm13 as setbm, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @p229 as c1, @p230 as c2, @p231 as c3, @p232 as c4, @p233 as c5, @p234 as c6, @p235 as c7, @p236 as c8, @p237 as c9, 
            @p238 as c10, @p239 as c11, @p240 as c12, @p241 as c13, @p242 as c14, @p243 as c15, @p244 as c16, @p245 as c17, @p246 as c18 union all
    select @rowguid14 as rowguid, @setbm14 as setbm, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @p248 as c1, @p249 as c2, @p250 as c3, @p251 as c4, @p252 as c5, @p253 as c6, @p254 as c7, @p255 as c8, @p256 as c9, 
            @p257 as c10, @p258 as c11, @p259 as c12, @p260 as c13, @p261 as c14, @p262 as c15, @p263 as c16, @p264 as c17, @p265 as c18 union all
    select @rowguid15 as rowguid, @setbm15 as setbm, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @p267 as c1, @p268 as c2, @p269 as c3, @p270 as c4, @p271 as c5, @p272 as c6, @p273 as c7, @p274 as c8, @p275 as c9, 
            @p276 as c10, @p277 as c11, @p278 as c12, @p279 as c13, @p280 as c14, @p281 as c15, @p282 as c16, @p283 as c17, @p284 as c18 union all
    select @rowguid16 as rowguid, @setbm16 as setbm, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @p286 as c1, @p287 as c2, @p288 as c3, @p289 as c4, @p290 as c5, @p291 as c6, @p292 as c7, @p293 as c8, @p294 as c9, 
            @p295 as c10, @p296 as c11, @p297 as c12, @p298 as c13, @p299 as c14, @p300 as c15, @p301 as c16, @p302 as c17, @p303 as c18 union all
    select @rowguid17 as rowguid, @setbm17 as setbm, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @p305 as c1, @p306 as c2, @p307 as c3, @p308 as c4, @p309 as c5, @p310 as c6, @p311 as c7, @p312 as c8, @p313 as c9, 
            @p314 as c10, @p315 as c11, @p316 as c12, @p317 as c13, @p318 as c14, @p319 as c15, @p320 as c16, @p321 as c17, @p322 as c18 union all
    select @rowguid18 as rowguid, @setbm18 as setbm, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @p324 as c1, @p325 as c2, @p326 as c3, @p327 as c4, @p328 as c5, @p329 as c6, @p330 as c7, @p331 as c8, @p332 as c9, 
            @p333 as c10, @p334 as c11, @p335 as c12, @p336 as c13, @p337 as c14, @p338 as c15, @p339 as c16, @p340 as c17, @p341 as c18 union all
    select @rowguid19 as rowguid, @setbm19 as setbm, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @p343 as c1, @p344 as c2, @p345 as c3, @p346 as c4, @p347 as c5, @p348 as c6, @p349 as c7, @p350 as c8, @p351 as c9, 
            @p352 as c10, @p353 as c11, @p354 as c12, @p355 as c13, @p356 as c14, @p357 as c15, @p358 as c16, @p359 as c17, @p360 as c18 union all
    select @rowguid20 as rowguid, @setbm20 as setbm, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @p362 as c1, @p363 as c2, @p364 as c3, @p365 as c4, @p366 as c5, @p367 as c6, @p368 as c7, @p369 as c8, @p370 as c9, 
            @p371 as c10, @p372 as c11, @p373 as c12, @p374 as c13, @p375 as c14, @p376 as c15, @p377 as c16, @p378 as c17, @p379 as c18 union all
    select @rowguid21 as rowguid, @setbm21 as setbm, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @p381 as c1
, @p382 as c2, @p383 as c3, @p384 as c4, @p385 as c5, @p386 as c6, @p387 as c7, @p388 as c8, @p389 as c9, 
            @p390 as c10, @p391 as c11, @p392 as c12, @p393 as c13, @p394 as c14, @p395 as c15, @p396 as c16, @p397 as c17, @p398 as c18 union all
    select @rowguid22 as rowguid, @setbm22 as setbm, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @p400 as c1, @p401 as c2, @p402 as c3, @p403 as c4, @p404 as c5, @p405 as c6, @p406 as c7, @p407 as c8, @p408 as c9, 
            @p409 as c10, @p410 as c11, @p411 as c12, @p412 as c13, @p413 as c14, @p414 as c15, @p415 as c16, @p416 as c17, @p417 as c18 union all
    select @rowguid23 as rowguid, @setbm23 as setbm, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @p419 as c1, @p420 as c2, @p421 as c3, @p422 as c4, @p423 as c5, @p424 as c6, @p425 as c7, @p426 as c8, @p427 as c9, 
            @p428 as c10, @p429 as c11, @p430 as c12, @p431 as c13, @p432 as c14, @p433 as c15, @p434 as c16, @p435 as c17, @p436 as c18 union all
    select @rowguid24 as rowguid, @setbm24 as setbm, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @p438 as c1, @p439 as c2, @p440 as c3, @p441 as c4, @p442 as c5, @p443 as c6, @p444 as c7, @p445 as c8, @p446 as c9, 
            @p447 as c10, @p448 as c11, @p449 as c12, @p450 as c13, @p451 as c14, @p452 as c15, @p453 as c16, @p454 as c17, @p455 as c18 union all
    select @rowguid25 as rowguid, @setbm25 as setbm, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @p457 as c1, @p458 as c2, @p459 as c3, @p460 as c4, @p461 as c5, @p462 as c6, @p463 as c7, @p464 as c8, @p465 as c9, 
            @p466 as c10, @p467 as c11, @p468 as c12, @p469 as c13, @p470 as c14, @p471 as c15, @p472 as c16, @p473 as c17, @p474 as c18 union all
    select @rowguid26 as rowguid, @setbm26 as setbm, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @p476 as c1, @p477 as c2, @p478 as c3, @p479 as c4, @p480 as c5, @p481 as c6, @p482 as c7, @p483 as c8, @p484 as c9, 
            @p485 as c10, @p486 as c11, @p487 as c12, @p488 as c13, @p489 as c14, @p490 as c15, @p491 as c16, @p492 as c17, @p493 as c18 union all
    select @rowguid27 as rowguid, @setbm27 as setbm, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @p495 as c1, @p496 as c2, @p497 as c3, @p498 as c4, @p499 as c5, @p500 as c6, @p501 as c7, @p502 as c8, @p503 as c9, 
            @p504 as c10, @p505 as c11, @p506 as c12, @p507 as c13, @p508 as c14, @p509 as c15, @p510 as c16, @p511 as c17, @p512 as c18 union all
    select @rowguid28 as rowguid, @setbm28 as setbm, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @p514 as c1, @p515 as c2, @p516 as c3, @p517 as c4, @p518 as c5, @p519 as c6, @p520 as c7, @p521 as c8, @p522 as c9, 
            @p523 as c10, @p524 as c11, @p525 as c12, @p526 as c13, @p527 as c14, @p528 as c15, @p529 as c16, @p530 as c17, @p531 as c18 union all
    select @rowguid29 as rowguid, @setbm29 as setbm, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @p533 as c1, @p534 as c2, @p535 as c3, @p536 as c4, @p537 as c5, @p538 as c6, @p539 as c7, @p540 as c8, @p541 as c9, 
            @p542 as c10, @p543 as c11, @p544 as c12, @p545 as c13, @p546 as c14, @p547 as c15, @p548 as c16, @p549 as c17, @p550 as c18 union all
    select @rowguid30 as rowguid, @setbm30 as setbm, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @p552 as c1, @p553 as c2, @p554 as c3, @p555 as c4, @p556 as c5, @p557 as c6, @p558 as c7, @p559 as c8, @p560 as c9, 
            @p561 as c10, @p562 as c11, @p563 as c12, @p564 as c13, @p565 as c14, @p566 as c15, @p567 as c16, @p568 as c17, @p569 as c18 union all
    select @rowguid31 as rowguid, @setbm31 as setbm, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @p571 as c1
, @p572 as c2, @p573 as c3, @p574 as c4, @p575 as c5, @p576 as c6, @p577 as c7, @p578 as c8, @p579 as c9, 
            @p580 as c10, @p581 as c11, @p582 as c12, @p583 as c13, @p584 as c14, @p585 as c15, @p586 as c16, @p587 as c17, @p588 as c18 union all
    select @rowguid32 as rowguid, @setbm32 as setbm, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @p590 as c1, @p591 as c2, @p592 as c3, @p593 as c4, @p594 as c5, @p595 as c6, @p596 as c7, @p597 as c8, @p598 as c9, 
            @p599 as c10, @p600 as c11, @p601 as c12, @p602 as c13, @p603 as c14, @p604 as c15, @p605 as c16, @p606 as c17, @p607 as c18 union all
    select @rowguid33 as rowguid, @setbm33 as setbm, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @p609 as c1, @p610 as c2, @p611 as c3, @p612 as c4, @p613 as c5, @p614 as c6, @p615 as c7, @p616 as c8, @p617 as c9, 
            @p618 as c10, @p619 as c11, @p620 as c12, @p621 as c13, @p622 as c14, @p623 as c15, @p624 as c16, @p625 as c17, @p626 as c18 union all
    select @rowguid34 as rowguid, @setbm34 as setbm, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @p628 as c1, @p629 as c2, @p630 as c3, @p631 as c4, @p632 as c5, @p633 as c6, @p634 as c7, @p635 as c8, @p636 as c9, 
            @p637 as c10, @p638 as c11, @p639 as c12, @p640 as c13, @p641 as c14, @p642 as c15, @p643 as c16, @p644 as c17, @p645 as c18 union all
    select @rowguid35 as rowguid, @setbm35 as setbm, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @p647 as c1, @p648 as c2, @p649 as c3, @p650 as c4, @p651 as c5, @p652 as c6, @p653 as c7, @p654 as c8, @p655 as c9, 
            @p656 as c10, @p657 as c11, @p658 as c12, @p659 as c13, @p660 as c14, @p661 as c15, @p662 as c16, @p663 as c17, @p664 as c18 union all
    select @rowguid36 as rowguid, @setbm36 as setbm, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @p666 as c1, @p667 as c2, @p668 as c3, @p669 as c4, @p670 as c5, @p671 as c6, @p672 as c7, @p673 as c8, @p674 as c9, 
            @p675 as c10, @p676 as c11, @p677 as c12, @p678 as c13, @p679 as c14, @p680 as c15, @p681 as c16, @p682 as c17, @p683 as c18 union all
    select @rowguid37 as rowguid, @setbm37 as setbm, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @p685 as c1, @p686 as c2, @p687 as c3, @p688 as c4, @p689 as c5, @p690 as c6, @p691 as c7, @p692 as c8, @p693 as c9, 
            @p694 as c10, @p695 as c11, @p696 as c12, @p697 as c13, @p698 as c14, @p699 as c15, @p700 as c16, @p701 as c17, @p702 as c18 union all
    select @rowguid38 as rowguid, @setbm38 as setbm, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @p704 as c1, @p705 as c2, @p706 as c3, @p707 as c4, @p708 as c5, @p709 as c6, @p710 as c7, @p711 as c8, @p712 as c9, 
            @p713 as c10, @p714 as c11, @p715 as c12, @p716 as c13, @p717 as c14, @p718 as c15, @p719 as c16, @p720 as c17, @p721 as c18 union all
    select @rowguid39 as rowguid, @setbm39 as setbm, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @p723 as c1
, @p724 as c2
, @p725 as c3
, @p726 as c4
, @p727 as c5
, @p728 as c6
, @p729 as c7
, @p730 as c8
, @p731 as c9
, 
            @p732 as c10
, @p733 as c11
, @p734 as c12
, @p735 as c13
, @p736 as c14
, @p737 as c15
, @p738 as c16
, @p739 as c17
, @p740 as c18
) as rows
    inner join [dbo].[member2] t with (rowlock) on rows.rowguid = t.[rowguid]
        and rows.rowguid is not null
    left outer join dbo.MSmerge_contents cont with (rowlock) on rows.rowguid = cont.rowguid 
    and cont.tablenick = 8260001
    where  ((rows.metadata_type = 2 and cont.rowguid is not NULL and cont.lineage = rows.lineage_old) or
           (rows.metadata_type = 3 and cont.rowguid is NULL))
           and rows.rowguid is not null
    
    select @rowcount = @@rowcount, @error = @@error

    select @rows_updated = @rowcount
    if (@rows_updated <> @rows_tobe_updated) or (@error <> 0)
    begin
        raiserror(20695, 16, -1, @rows_updated, @rows_tobe_updated, 'member2')
        set @errcode= 3
        goto Failure
    end

    update dbo.MSmerge_contents with (rowlock)
    set generation = rows.generation,
        lineage = rows.lineage_new,
        colv1 = rows.colv
    from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage_new1 as lineage_new, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage_new2 as lineage_new, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage_new3 as lineage_new, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage_new4 as lineage_new, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage_new5 as lineage_new, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage_new6 as lineage_new, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage_new7 as lineage_new, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage_new8 as lineage_new, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage_new9 as lineage_new, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage_new10 as lineage_new, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage_new11 as lineage_new, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage_new12 as lineage_new, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage_new13 as lineage_new, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage_new14 as lineage_new, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage_new15 as lineage_new, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage_new16 as lineage_new, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage_new17 as lineage_new, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage_new18 as lineage_new, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage_new19 as lineage_new, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage_new20 as lineage_new, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage_new21 as lineage_new, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage_new22 as lineage_new, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage_new23 as lineage_new, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage_new24 as lineage_new, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage_new25 as lineage_new, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage_new26 as lineage_new, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage_new27 as lineage_new, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage_new28 as lineage_new, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage_new29 as lineage_new, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage_new30 as lineage_new, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage_new31 as lineage_new, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage_new32 as lineage_new, @colv32 as colv
 union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage_new33 as lineage_new, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage_new34 as lineage_new, @colv34 as colv union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage_new35 as lineage_new, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage_new36 as lineage_new, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage_new37 as lineage_new, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage_new38 as lineage_new, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage_new39 as lineage_new, @colv39 as colv

    ) as rows
    inner join dbo.MSmerge_contents cont with (rowlock) 
    on cont.rowguid = rows.rowguid and cont.tablenick = 8260001
    and rows.rowguid is not NULL 
    and rows.lineage_new is not NULL
    option (force order, loop join)
    select @cont_rows_updated = @@rowcount, @error = @@error
    if @error<>0
    begin
        set @errcode= 3
        goto Failure
    end

    if @cont_rows_updated <> @rows_tobe_updated
    begin

        insert into dbo.MSmerge_contents with (rowlock)
        (tablenick, rowguid, lineage, colv1, generation)
        select 8260001, rows.rowguid, rows.lineage_new, rows.colv, rows.generation
        from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage_new1 as lineage_new, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage_new2 as lineage_new, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage_new3 as lineage_new, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage_new4 as lineage_new, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage_new5 as lineage_new, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage_new6 as lineage_new, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage_new7 as lineage_new, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage_new8 as lineage_new, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage_new9 as lineage_new, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage_new10 as lineage_new, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage_new11 as lineage_new, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage_new12 as lineage_new, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage_new13 as lineage_new, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage_new14 as lineage_new, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage_new15 as lineage_new, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage_new16 as lineage_new, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage_new17 as lineage_new, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage_new18 as lineage_new, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage_new19 as lineage_new, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage_new20 as lineage_new, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage_new21 as lineage_new, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage_new22 as lineage_new, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage_new23 as lineage_new, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage_new24 as lineage_new, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage_new25 as lineage_new, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage_new26 as lineage_new, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage_new27 as lineage_new, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage_new28 as lineage_new, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage_new29 as lineage_new, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage_new30 as lineage_new, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage_new31 as lineage_new, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage_new32 as lineage_new, @colv32 as colv
 union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage_new33 as lineage_new, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage_new34 as lineage_new, @colv34 as colv union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage_new35 as lineage_new, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage_new36 as lineage_new, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage_new37 as lineage_new, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage_new38 as lineage_new, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage_new39 as lineage_new, @colv39 as colv

        ) as rows
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 8260001
        and rows.rowguid is not NULL
        and rows.lineage_new is not NULL
        where cont.rowguid is NULL
        and rows.rowguid is not NULL
        and rows.lineage_new is not NULL
        
        if @@error<>0
        begin
            set @errcode= 3
            goto Failure
        end
    end

    exec @retcode = sys.sp_MSdeletemetadataactionrequest 'CEFA968C-E172-41FA-B5A5-680EAD11935A', 8260001, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39
    if @retcode<>0 or @@error<>0
        goto Failure
    

    commit tran
    return 1

Failure:
    rollback tran batchupdateproc
    commit tran
    return 0
end


go

update dbo.sysmergepartitioninfo 
    set column_list = 't.[member_no], t.[lastname], t.[firstname], t.[middleinitial], t.[street], t.[city], t.[state_prov], t.[country], t.[mail_code], t.[phone_no], t.[photograph], t.[issue_dt], t.[expr_dt], t.[region_no], t.[corp_no], t.[prev_balance], t.[curr_balance], t.[member_code], t.[rowguid]', 
        column_list_blob = 't.[member_no], t.[lastname], t.[firstname], t.[middleinitial], t.[street], t.[city], t.[state_prov], t.[country], t.[mail_code], t.[phone_no], t.[issue_dt], t.[expr_dt], t.[region_no], t.[corp_no], t.[prev_balance], t.[curr_balance], t.[member_code], t.[rowguid], t.[photograph]'
    where artid = 'CAD585A8-9B67-48A6-AAA4-E0C60E400407' and pubid = 'CEFA968C-E172-41FA-B5A5-680EAD11935A'

go
SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON

go

    create procedure dbo.[MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA] (
        @maxschemaguidforarticle uniqueidentifier,
        @type int output, 
        @rowguid uniqueidentifier=NULL,
        @enumentirerowmetadata bit= 1,
        @blob_cols_at_the_end bit=0,
        @logical_record_parent_rowguid uniqueidentifier = '00000000-0000-0000-0000-000000000000',
        @metadata_type tinyint = 0,
        @lineage_old varbinary(311) = NULL,
        @rowcount int = NULL output
        ) 
    as
    begin
        declare @retcode    int
        
        set nocount on
            
        if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
        begin       
            RAISERROR (14126, 11, -1)
            return (1)
        end 

    if @type = 1
        begin
            select 
t.[member_no]
,
        t.[lastname]
,
        t.[firstname]
,
        t.[middleinitial]
,
        t.[street]
,
        t.[city]
,
        t.[state_prov]
,
        t.[country]
,
        t.[mail_code]
,
        t.[phone_no]
,
        t.[photograph]
,
        t.[issue_dt]
,
        t.[expr_dt]
,
        t.[region_no]
,
        t.[corp_no]
,
        t.[prev_balance]
,
        t.[curr_balance]
,
        t.[member_code]
,
        t.rowguidcol
          from [dbo].[member2] t where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)
    end 
    else if @type < 4 
        begin
            -- case one: no blob gen optimization
            if @blob_cols_at_the_end=0
            begin
                select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end as lineage,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end as colv1,
                
t.[member_no]
,
        t.[lastname]
,
        t.[firstname]
,
        t.[middleinitial]
,
        t.[street]
,
        t.[city]
,
        t.[state_prov]
,
        t.[country]
,
        t.[mail_code]
,
        t.[phone_no]
,
        t.[photograph]
,
        t.[issue_dt]
,
        t.[expr_dt]
,
        t.[region_no]
,
        t.[corp_no]
,
        t.[prev_balance]
,
        t.[curr_balance]
,
        t.[member_code]
,
        t.rowguidcol

                from #cont c , [dbo].[member2] t with (rowlock)
                where t.rowguidcol = c.rowguid
                order by t.rowguidcol 
                
            if @@ERROR<>0 return(1)
            end
  
            -- case two: blob gen optimization
            else 
            begin
                select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end as lineage,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end as colv1,
t.[member_no]
 ,
        t.[lastname]
 ,
        t.[firstname]
 ,
        t.[middleinitial]
 ,
        t.[street]
 ,
        t.[city]
 ,
        t.[state_prov]
 ,
        t.[country]
 ,
        t.[mail_code]
 ,
        t.[phone_no]
 ,
        t.[issue_dt]
 ,
        t.[expr_dt]
 ,
        t.[region_no]
 ,
        t.[corp_no]
 ,
        t.[prev_balance]
 ,
        t.[curr_balance]
 ,
        t.[member_code]
 ,
        t.rowguidcol
 ,
        t.[photograph]

                from #cont c,[dbo].[member2] t with (rowlock)
              where t.rowguidcol = c.rowguid
                 order by t.rowguidcol 
                 
            if @@ERROR<>0 return(1)
            end
        end
   else if @type = 4
    begin
        set @type = 0
        if exists (select * from [dbo].[member2] where rowguidcol = @rowguid)
            set @type = 3
        if @@ERROR<>0 return(1)
    end

    else if @type = 5
    begin
         
        delete [dbo].[member2] where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)

        delete from dbo.MSmerge_metadataaction_request
            where tablenick=8260001 and rowguid=@rowguid
    end 

    else if @type = 6 -- sp_MSenumcolumns
    begin
        select 
t.[member_no]
,
        t.[lastname]
,
        t.[firstname]
,
        t.[middleinitial]
,
        t.[street]
,
        t.[city]
,
        t.[state_prov]
,
        t.[country]
,
        t.[mail_code]
,
        t.[phone_no]
,
        t.[photograph]
,
        t.[issue_dt]
,
        t.[expr_dt]
,
        t.[region_no]
,
        t.[corp_no]
,
        t.[prev_balance]
,
        t.[curr_balance]
,
        t.[member_code]
,
        t.rowguidcol
         from [dbo].[member2] t where 1=2
        if @@ERROR<>0 return(1)
    end

    else if @type = 7 -- sp_MSlocktable
    begin
        select 1 from [dbo].[member2] with (tablock holdlock) where 1 = 2
        if @@ERROR<>0 return(1)
    end

    else if @type = 8 -- put update lock
    begin
        if not exists (select * from [dbo].[member2] with (UPDLOCK HOLDLOCK) where rowguidcol = @rowguid)
        begin
            RAISERROR(20031 , 16, -1)
            return(1)
        end
    end
    else if @type = 9
    begin
        declare @oldmaxversion int, @replnick binary(6)
                , @cur_article_rowcount int, @column_tracking int
                        
        select @replnick = 0xe172cefa968c

        select top 1 @oldmaxversion = maxversion_at_cleanup,
                     @column_tracking = column_tracking
        from dbo.sysmergearticles 
        where nickname = 8260001
        
        select @cur_article_rowcount = count(*) from #rows 
        where tablenick = 8260001
            
        update dbo.MSmerge_contents 
        set lineage = { fn UPDATELINEAGE(lineage, @replnick, @oldmaxversion+1) }
        where tablenick = 8260001
        and rowguid in (select rowguid from #rows where tablenick = 8260001) 

        if @@rowcount <> @cur_article_rowcount
        begin
            declare @lineage varbinary(311), @colv1 varbinary(1)
                    , @cur_rowguid uniqueidentifier, @prev_rowguid uniqueidentifier
            set @lineage = { fn UPDATELINEAGE(0x0, @replnick, @oldmaxversion+1) }
            if @column_tracking <> 0
                set @colv1 = 0xFF
            else
                set @colv1 = NULL
                
            select top 1 @cur_rowguid = rowguid from #rows
            where tablenick = 8260001
            order by rowguid
            
            while @cur_rowguid is not null
            begin
                if not exists (select * from dbo.MSmerge_contents 
                                where tablenick = 8260001
                                and rowguid = @cur_rowguid)
                begin
                    begin tran 
                    save tran insert_contents_row 

                    if exists (select * from [dbo].[member2]with (holdlock) where rowguidcol = @cur_rowguid)
                    begin
                        exec @retcode = sys.sp_MSevaluate_change_membership_for_row @tablenick = 8260001, @rowguid = @cur_rowguid
                        if @retcode <> 0 or @@error <> 0
                        begin
                            rollback tran insert_contents_row
                            return 1
                        end
                        insert into dbo.MSmerge_contents (rowguid, tablenick, generation, lineage, colv1, logical_record_parent_rowguid)
                            values (@cur_rowguid, 8260001, 0, @lineage, @colv1, @logical_record_parent_rowguid)
                    end
                    commit tran
                end
                
                select @prev_rowguid = @cur_rowguid
                select @cur_rowguid = NULL
                
                select top 1 @cur_rowguid = rowguid from #rows
                where tablenick = 8260001
                and rowguid > @prev_rowguid
                order by rowguid
            end
        end 

        select 
            r.tablenick, 
            r.rowguid, 
            mc.generation,
            case @enumentirerowmetadata
                when 0 then null
                else mc.lineage
            end,
            case @enumentirerowmetadata
                when 0 then null
                else mc.colv1
            end,
            
t.[member_no]
,
        t.[lastname]
,
        t.[firstname]
,
        t.[middleinitial]
,
        t.[street]
,
        t.[city]
,
        t.[state_prov]
,
        t.[country]
,
        t.[mail_code]
,
        t.[phone_no]
,
        t.[photograph]
,
        t.[issue_dt]
,
        t.[expr_dt]
,
        t.[region_no]
,
        t.[corp_no]
,
        t.[prev_balance]
,
        t.[curr_balance]
,
        t.[member_code]
,
        t.rowguidcol
         from #rows r left outer join [dbo].[member2] t on r.rowguid = t.rowguidcol and r.tablenick = 8260001
                 left outer join dbo.MSmerge_contents mc on
                 mc.tablenick = 8260001 and mc.rowguid = t.rowguidcol
                 where r.tablenick = 8260001
         order by r.idx
         
        if @@ERROR<>0 return(1)
    end 

        else if @type = 10  
        begin
            select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end,
                null,
                
t.[member_no]
,
        t.[lastname]
,
        t.[firstname]
,
        t.[middleinitial]
,
        t.[street]
,
        t.[city]
,
        t.[state_prov]
,
        t.[country]
,
        t.[mail_code]
,
        t.[phone_no]
,
        t.[photograph]
,
        t.[issue_dt]
,
        t.[expr_dt]
,
        t.[region_no]
,
        t.[corp_no]
,
        t.[prev_balance]
,
        t.[curr_balance]
,
        t.[member_code]
,
        t.rowguidcol
         from #cont c,[dbo].[member2] t with (rowlock) where
                      t.rowguidcol = c.rowguid
             order by t.rowguidcol 
                        
            if @@ERROR<>0 return(1)
        end

    else if @type = 11
    begin
         
        -- we will do a delete with metadata match
        if @metadata_type = 0
        begin
            delete from [dbo].[member2] where [rowguid] = @rowguid
            select @rowcount = @@rowcount
            if @rowcount <> 1
            begin
                RAISERROR(20031 , 16, -1)
                return(1)
            end
        end
        else
        begin
            if @metadata_type = 3
                delete [dbo].[member2] from [dbo].[member2] t
                    where t.[rowguid] = @rowguid and 
                        not exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 8260001)
            else if @metadata_type = 5 or @metadata_type = 6
                delete [dbo].[member2] from [dbo].[member2] t
                    where t.[rowguid] = @rowguid and 
                         not exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 8260001 and
                                                c.lineage <> @lineage_old)
                                                
            else
                delete [dbo].[member2] from [dbo].[member2] t
                    where t.[rowguid] = @rowguid and 
                         exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 8260001 and
                                                c.lineage = @lineage_old)
            select @rowcount = @@rowcount
            if @rowcount <> 1 
            begin
                if not exists (select * from [dbo].[member2] where [rowguid] = @rowguid)
                begin
                    RAISERROR(20031 , 16, -1)
                    return(1)
                end
            end
        end
        if @@ERROR<>0 
        begin
            delete from dbo.MSmerge_metadataaction_request
                where tablenick=8260001 and rowguid=@rowguid

            return(1)
        end        
    end

    else if @type = 12
    begin 
        -- this type indicates metadata type selection
        declare @maxversion int
        declare @error int
        
        select @maxversion= maxversion_at_cleanup from dbo.sysmergearticles 
            where nickname = 8260001 and pubid = 'CEFA968C-E172-41FA-B5A5-680EAD11935A'
        if @error <> 0 
            return 1
        select case when (cont.generation is NULL and tomb.generation is null) 
                    then 0 
                    else isnull(cont.generation, tomb.generation) 
               end as generation, 
               case when t.[rowguid] is null 
                    then (case when tomb.rowguid is NULL then 0 else tomb.type end) 
                    else (case when cont.rowguid is null then 3 else 2 end) 
               end as type,
               case when tomb.rowguid is null 
                    then cont.lineage 
                    else tomb.lineage
               end as lineage, 
               cont.colv1 as colv, 
               @maxversion as maxversion
        from
        (select @rowguid as rowguid) as rows 
        left outer join [dbo].[member2] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not null
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 8260001
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid and tomb.tablenick = 8260001
        where rows.rowguid is not null
        
        select @error = @@error
        if @error <> 0 
        begin
            --raiserror(@error, 16, -1)
            return 1
        end
    end

    return(0)
end


go

create procedure dbo.[MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA_metadata]
( 
    @rowguid1 uniqueidentifier,
    @rowguid2 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @rowguid41 uniqueidentifier = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @rowguid50 uniqueidentifier = NULL,

    @rowguid51 uniqueidentifier = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @rowguid61 uniqueidentifier = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @rowguid64 uniqueidentifier = NULL,
    @rowguid65 uniqueidentifier = NULL,
    @rowguid66 uniqueidentifier = NULL,
    @rowguid67 uniqueidentifier = NULL,
    @rowguid68 uniqueidentifier = NULL,
    @rowguid69 uniqueidentifier = NULL,
    @rowguid70 uniqueidentifier = NULL,
    @rowguid71 uniqueidentifier = NULL,
    @rowguid72 uniqueidentifier = NULL,
    @rowguid73 uniqueidentifier = NULL,
    @rowguid74 uniqueidentifier = NULL,
    @rowguid75 uniqueidentifier = NULL,
    @rowguid76 uniqueidentifier = NULL,
    @rowguid77 uniqueidentifier = NULL,
    @rowguid78 uniqueidentifier = NULL,
    @rowguid79 uniqueidentifier = NULL,
    @rowguid80 uniqueidentifier = NULL,
    @rowguid81 uniqueidentifier = NULL,
    @rowguid82 uniqueidentifier = NULL,
    @rowguid83 uniqueidentifier = NULL,
    @rowguid84 uniqueidentifier = NULL,
    @rowguid85 uniqueidentifier = NULL,
    @rowguid86 uniqueidentifier = NULL,
    @rowguid87 uniqueidentifier = NULL,
    @rowguid88 uniqueidentifier = NULL,
    @rowguid89 uniqueidentifier = NULL,
    @rowguid90 uniqueidentifier = NULL,
    @rowguid91 uniqueidentifier = NULL,
    @rowguid92 uniqueidentifier = NULL,
    @rowguid93 uniqueidentifier = NULL,
    @rowguid94 uniqueidentifier = NULL,
    @rowguid95 uniqueidentifier = NULL,
    @rowguid96 uniqueidentifier = NULL,
    @rowguid97 uniqueidentifier = NULL,
    @rowguid98 uniqueidentifier = NULL,
    @rowguid99 uniqueidentifier = NULL,
    @rowguid100 uniqueidentifier = NULL
) 

as
begin
    declare @retcode    int
    declare @maxversion int
    set nocount on
        
    if ({ fn ISPALUSER('CEFA968C-E172-41FA-B5A5-680EAD11935A') } <> 1)
    begin       
        RAISERROR (14126, 11, -1)
        return (1)
    end
    
    select @maxversion= maxversion_at_cleanup from dbo.sysmergearticles 
        where nickname = 8260001 and pubid = 'CEFA968C-E172-41FA-B5A5-680EAD11935A'


        select case when (cont.generation is NULL and tomb.generation is null) then 0 else isnull(cont.generation, tomb.generation) end as generation, 
               case when t.[rowguid] is null then (case when tomb.rowguid is NULL then 0 else tomb.type end) else (case when cont.rowguid is null then 3 else 2 end) end as type,
               case when tomb.rowguid is null then cont.lineage else tomb.lineage end as lineage,  
               cont.colv1 as colv,
               @maxversion as maxversion,
               rows.rowguid as rowguid
    

        from
        ( 
        select @rowguid1 as rowguid, 1 as sortcol union all
        select @rowguid2 as rowguid, 2 as sortcol union all
        select @rowguid3 as rowguid, 3 as sortcol union all
        select @rowguid4 as rowguid, 4 as sortcol union all
        select @rowguid5 as rowguid, 5 as sortcol union all
        select @rowguid6 as rowguid, 6 as sortcol union all
        select @rowguid7 as rowguid, 7 as sortcol union all
        select @rowguid8 as rowguid, 8 as sortcol union all
        select @rowguid9 as rowguid, 9 as sortcol union all
        select @rowguid10 as rowguid, 10 as sortcol union all
        select @rowguid11 as rowguid, 11 as sortcol union all
        select @rowguid12 as rowguid, 12 as sortcol union all
        select @rowguid13 as rowguid, 13 as sortcol union all
        select @rowguid14 as rowguid, 14 as sortcol union all
        select @rowguid15 as rowguid, 15 as sortcol union all
        select @rowguid16 as rowguid, 16 as sortcol union all
        select @rowguid17 as rowguid, 17 as sortcol union all
        select @rowguid18 as rowguid, 18 as sortcol union all
        select @rowguid19 as rowguid, 19 as sortcol union all
        select @rowguid20 as rowguid, 20 as sortcol union all
        select @rowguid21 as rowguid, 21 as sortcol union all
        select @rowguid22 as rowguid, 22 as sortcol union all
        select @rowguid23 as rowguid, 23 as sortcol union all
        select @rowguid24 as rowguid, 24 as sortcol union all
        select @rowguid25 as rowguid, 25 as sortcol union all
        select @rowguid26 as rowguid, 26 as sortcol union all
        select @rowguid27 as rowguid, 27 as sortcol union all
        select @rowguid28 as rowguid, 28 as sortcol union all
        select @rowguid29 as rowguid, 29 as sortcol union all
        select @rowguid30 as rowguid, 30 as sortcol union all
        select @rowguid31 as rowguid, 31 as sortcol union all

        select @rowguid32 as rowguid, 32 as sortcol union all
        select @rowguid33 as rowguid, 33 as sortcol union all
        select @rowguid34 as rowguid, 34 as sortcol union all
        select @rowguid35 as rowguid, 35 as sortcol union all
        select @rowguid36 as rowguid, 36 as sortcol union all
        select @rowguid37 as rowguid, 37 as sortcol union all
        select @rowguid38 as rowguid, 38 as sortcol union all
        select @rowguid39 as rowguid, 39 as sortcol union all
        select @rowguid40 as rowguid, 40 as sortcol union all
        select @rowguid41 as rowguid, 41 as sortcol union all
        select @rowguid42 as rowguid, 42 as sortcol union all
        select @rowguid43 as rowguid, 43 as sortcol union all
        select @rowguid44 as rowguid, 44 as sortcol union all
        select @rowguid45 as rowguid, 45 as sortcol union all
        select @rowguid46 as rowguid, 46 as sortcol union all
        select @rowguid47 as rowguid, 47 as sortcol union all
        select @rowguid48 as rowguid, 48 as sortcol union all
        select @rowguid49 as rowguid, 49 as sortcol union all
        select @rowguid50 as rowguid, 50 as sortcol union all
        select @rowguid51 as rowguid, 51 as sortcol union all
        select @rowguid52 as rowguid, 52 as sortcol union all
        select @rowguid53 as rowguid, 53 as sortcol union all
        select @rowguid54 as rowguid, 54 as sortcol union all
        select @rowguid55 as rowguid, 55 as sortcol union all
        select @rowguid56 as rowguid, 56 as sortcol union all
        select @rowguid57 as rowguid, 57 as sortcol union all
        select @rowguid58 as rowguid, 58 as sortcol union all
        select @rowguid59 as rowguid, 59 as sortcol union all
        select @rowguid60 as rowguid, 60 as sortcol union all
        select @rowguid61 as rowguid, 61 as sortcol union all
        select @rowguid62 as rowguid, 62 as sortcol union all
 
        select @rowguid63 as rowguid, 63 as sortcol union all
        select @rowguid64 as rowguid, 64 as sortcol union all
        select @rowguid65 as rowguid, 65 as sortcol union all
        select @rowguid66 as rowguid, 66 as sortcol union all
        select @rowguid67 as rowguid, 67 as sortcol union all
        select @rowguid68 as rowguid, 68 as sortcol union all
        select @rowguid69 as rowguid, 69 as sortcol union all
        select @rowguid70 as rowguid, 70 as sortcol union all
        select @rowguid71 as rowguid, 71 as sortcol union all
        select @rowguid72 as rowguid, 72 as sortcol union all
        select @rowguid73 as rowguid, 73 as sortcol union all
        select @rowguid74 as rowguid, 74 as sortcol union all
        select @rowguid75 as rowguid, 75 as sortcol union all
        select @rowguid76 as rowguid, 76 as sortcol union all
        select @rowguid77 as rowguid, 77 as sortcol union all
        select @rowguid78 as rowguid, 78 as sortcol union all
        select @rowguid79 as rowguid, 79 as sortcol union all
        select @rowguid80 as rowguid, 80 as sortcol union all
        select @rowguid81 as rowguid, 81 as sortcol union all
        select @rowguid82 as rowguid, 82 as sortcol union all
        select @rowguid83 as rowguid, 83 as sortcol union all
        select @rowguid84 as rowguid, 84 as sortcol union all
        select @rowguid85 as rowguid, 85 as sortcol union all
        select @rowguid86 as rowguid, 86 as sortcol union all
        select @rowguid87 as rowguid, 87 as sortcol union all
        select @rowguid88 as rowguid, 88 as sortcol union all
        select @rowguid89 as rowguid, 89 as sortcol union all
        select @rowguid90 as rowguid, 90 as sortcol union all
        select @rowguid91 as rowguid, 91 as sortcol union all
        select @rowguid92 as rowguid, 92 as sortcol union all
        select @rowguid93 as rowguid, 93 as sortcol union all
 
        select @rowguid94 as rowguid, 94 as sortcol union all
        select @rowguid95 as rowguid, 95 as sortcol union all
        select @rowguid96 as rowguid, 96 as sortcol union all
        select @rowguid97 as rowguid, 97 as sortcol union all
        select @rowguid98 as rowguid, 98 as sortcol union all
        select @rowguid99 as rowguid, 99 as sortcol union all
        select @rowguid100 as rowguid, 100 as sortcol
        ) as rows 

        left outer join [dbo].[member2] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not null
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 8260001
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid and tomb.tablenick = 8260001
        where rows.rowguid is not null
        order by rows.sortcol
                
        if @@error <> 0 
            return 1
    end
    

go
Create procedure dbo.[MSmerge_cft_sp_CAD585A89B6748A6CEFA968CE17241FA] ( 
@p1 [numeric_id], 
        @p2 [shortstring], 
        @p3 [shortstring], 
        @p4 [letter], 
        @p5 [shortstring], 
        @p6 [shortstring], 
        @p7 [statecode], 
        @p8 [countrycode], 
        @p9 [mailcode], 
        @p10 [phonenumber], 
        @p11 image, 
        @p12 datetime, 
        @p13 datetime, 
        @p14 [numeric_id], 
        @p15 [numeric_id], 
        @p16 money, 
        @p17 money, 
        @p18 [status_code], 
        @p19 uniqueidentifier, 
        @p20  nvarchar(255) 
, @conflict_type int,  @reason_code int,  @reason_text nvarchar(720)
, @pubid uniqueidentifier, @create_time datetime = NULL
, @tablenick int = 0, @source_id uniqueidentifier = NULL, @check_conflicttable_existence bit = 0 
) as
declare @retcode int
-- security check
exec @retcode = sys.sp_MSrepl_PAL_rolecheck @objid = 667149422, @pubid = 'CEFA968C-E172-41FA-B5A5-680EAD11935A'
if @@error <> 0 or @retcode <> 0 return 1 

if 1 = @check_conflicttable_existence
begin
    if 667149422 is null return 0
end


    if @source_id is NULL 
        select @source_id = subid from dbo.sysmergesubscriptions 
            where lower(@p20) = LOWER(subscriber_server) + '.' + LOWER(db_name) 

    if @source_id is NULL select @source_id = newid() 
  
    set @create_time=getdate()

  if exists (select * from MSmerge_conflicts_info info inner join [dbo].[MSmerge_conflict_PublicaCredit_member2] ct 
    on ct.rowguidcol=info.rowguid and 
       ct.origin_datasource_id = info.origin_datasource_id
     where info.rowguid = @p19 and info.origin_datasource = @p20 and info.tablenick = @tablenick)
    begin
        update [dbo].[MSmerge_conflict_PublicaCredit_member2] with (rowlock) set 
[member_no] = @p1
,
        [lastname] = @p2
,
        [firstname] = @p3
,
        [middleinitial] = @p4
,
        [street] = @p5
,
        [city] = @p6
,
        [state_prov] = @p7
,
        [country] = @p8
,
        [mail_code] = @p9
,
        [phone_no] = @p10
,
        [photograph] = @p11
,
        [issue_dt] = @p12
,
        [expr_dt] = @p13
,
        [region_no] = @p14
,
        [corp_no] = @p15
,
        [prev_balance] = @p16
,
        [curr_balance] = @p17
,
        [member_code] = @p18
 from [dbo].[MSmerge_conflict_PublicaCredit_member2] ct inner join MSmerge_conflicts_info info 
        on ct.rowguidcol=info.rowguid and 
           ct.origin_datasource_id = info.origin_datasource_id
 where info.rowguid = @p19 and info.origin_datasource = @p20 and info.tablenick = @tablenick


    end
    else
    begin
        insert into [dbo].[MSmerge_conflict_PublicaCredit_member2] (
[member_no]
,
        [lastname]
,
        [firstname]
,
        [middleinitial]
,
        [street]
,
        [city]
,
        [state_prov]
,
        [country]
,
        [mail_code]
,
        [phone_no]
,
        [photograph]
,
        [issue_dt]
,
        [expr_dt]
,
        [region_no]
,
        [corp_no]
,
        [prev_balance]
,
        [curr_balance]
,
        [member_code]
,
        [rowguid]
,
        [origin_datasource_id]
) values (

@p1
,
        @p2
,
        @p3
,
        @p4
,
        @p5
,
        @p6
,
        @p7
,
        @p8
,
        @p9
,
        @p10
,
        @p11
,
        @p12
,
        @p13
,
        @p14
,
        @p15
,
        @p16
,
        @p17
,
        @p18
,
        @p19
,
         @source_id 
)

    end

    
    if exists (select * from MSmerge_conflicts_info info where tablenick=@tablenick and rowguid=@p19 and info.origin_datasource= @p20 and info.conflict_type not in (4,7,8,12))
    begin
        update MSmerge_conflicts_info with (rowlock) 
            set conflict_type=@conflict_type, 
                reason_code=@reason_code,
                reason_text=@reason_text,
                pubid=@pubid,
                MSrepl_create_time=@create_time
            where tablenick=@tablenick and rowguid=@p19 and origin_datasource= @p20
            and conflict_type not in (4,7,8,12)
    end
    else    
    begin
    
        insert MSmerge_conflicts_info with (rowlock) 
            values(@tablenick, @p19, @p20, @conflict_type, @reason_code, @reason_text,  @pubid, @create_time, @source_id)
    end

        declare @error    int
        set @error= @reason_code

    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[member2] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 8260001 and
                (

                        (t.[member_no]=@p1)

                        )
            end

go

update dbo.sysmergearticles 
    set insert_proc = 'MSmerge_ins_sp_CAD585A89B6748A6CEFA968CE17241FA',
        select_proc = 'MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA',
        metadata_select_proc = 'MSmerge_sel_sp_CAD585A89B6748A6CEFA968CE17241FA_metadata',
        update_proc = 'MSmerge_upd_sp_CAD585A89B6748A6CEFA968CE17241FA',
        ins_conflict_proc = 'MSmerge_cft_sp_CAD585A89B6748A6CEFA968CE17241FA',
        delete_proc = 'MSmerge_del_sp_CAD585A89B6748A6CEFA968CE17241FA'
    where artid = 'CAD585A8-9B67-48A6-AAA4-E0C60E400407' and pubid = 'CEFA968C-E172-41FA-B5A5-680EAD11935A'

go

	if object_id('sp_MSpostapplyscript_forsubscriberprocs','P') is not NULL
		exec sys.sp_MSpostapplyscript_forsubscriberprocs @procsuffix = 'CAD585A89B6748A6CEFA968CE17241FA'

go
