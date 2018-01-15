begin
    PL_FLOW.CreateProcessInstance(
        prce_id_in=>30,             -- 10 is process id of file bonus request process
        prin_id_in=>1
    );
end;

begin 
    PL_FLOW.StartProcess( 
        prin_id_in  => 1, 
        pati_id_in  => 1 
    ); 
end;


begin
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 3,
        state_in    => 'RUNNING',
		pati_id_in  => 1
    );
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 3,
        state_in    => 'COMPLETED',
		pati_id_in  => 1
    );
end;

begin
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 5,
        state_in    => 'RUNNING',
		pati_id_in  => 1
    );
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 5,
        state_in    => 'COMPLETED',
		pati_id_in  => 1
    );
end;

begin
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 9,
        state_in    => 'RUNNING',
		pati_id_in  => 1
    );
    PL_FLOW.ChangeActivityInstanceState(
        acin_id_in  => 9,
        state_in    => 'COMPLETED',
		pati_id_in  => 1
    );
end;