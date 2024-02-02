<script lang="ts">
  import { goto } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  let rlink = ''
  let _onload = false

  let form_msg = ''
  let msg_type = ''

  const submit = async () => {
    _onload = true

    const url = `/_rd/rmstems?rlink=${rlink}`
    const res = await fetch(url, { method: 'POST' })
    _onload = false

    if (!res.ok) {
      form_msg = await res.text()
      msg_type = 'err'
    } else {
      const { sname, sn_id } = await res.json()
      goto(`/rm/${sname}/${sn_id}`)
    }
  }
</script>

<form action="/_rm/rmstems" method="GET" on:submit|preventDefault={submit}>
  <div class="form-field">
    <label for="rlink" class="form-label">Liên kết nhúng ngoài</label>
    <input type="text" class="m-input" name="rlink" bind:value={rlink} />
  </div>

  {#if form_msg}
    <div class="form-msg _{msg_type}">{form_msg}</div>
  {/if}

  <div class="form-action">
    <button
      type="submit"
      class="m-btn _success _fill _lg"
      disabled={!rlink || _onload}>
      <SIcon name={_onload ? 'loader-2' : 'send'} spin={_onload} />
      <span>Thêm nguồn</span>
      <SIcon name="privi-1" iset="icons" />
    </button>
  </div>
</form>

<style lang="scss">
  form {
    max-width: 30rem;
    padding: 0.75rem;
    margin: 1.5rem;
  }

  input {
    display: block;
    width: 100%;
  }

  .form-action {
    margin-top: 1.5rem;
  }

  // article {
  //   @include margin-y(var(--gutter));

  //   padding-bottom: 1rem;

  //   > :global(* + *) {
  //     margin-top: 1rem;
  //   }
  // }

  // summary {
  //   @include ftsize(lg);
  //   margin-bottom: 0.75rem;
  // }

  // .source {
  //   display: flex;
  //   max-width: 30rem;
  // }

  // .search {
  //   text-align: center;
  //   a {
  //     display: block;
  //   }
  // }

  // .desc {
  //   @include ftsize(xs);
  //   @include fgcolor(tert);
  //   max-width: 14rem;
  //   line-height: 1rem;
  //   padding: 0.25rem 0.5rem;
  // }

  // a {
  //   @include fgcolor(primary, 5);
  // }

  // .protip {
  //   // margin: 1.5rem 0;
  //   // line-height: 1rem;
  //   font-style: italic;
  //   @include fgcolor(warning, 5);
  // }

  // .extra {
  //   @include ftsize(sm);
  //   line-height: 1rem;
  //   @include fgcolor(tert);
  // }
</style>
