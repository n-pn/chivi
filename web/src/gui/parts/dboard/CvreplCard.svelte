<script lang="ts">
  import { page } from '$app/stores'

  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'
  import CvreplForm from './CvreplForm.svelte'

  export let cvrepl: CV.Cvrepl
  export let on_focus = false
  export let nest_level = 0

  $: _user = $page.data._user
  $: is_owner = _user.uname == cvrepl.u_dname
  $: can_edit = _user.privi > 3 || (is_owner && _user.privi >= 0)

  let show_repl = false

  async function toggle_like() {
    const action = cvrepl.self_liked ? 'unlike' : 'like'
    const api_url = `/_db/!repls/${cvrepl.id}/${action}`
    const api_res = await fetch(api_url, { method: 'PUT' })

    if (!api_res.ok) {
      alert(await api_res.text())
    } else {
      const payload = await api_res.json()
      cvrepl.like_count = payload.like_count
      cvrepl.self_liked = !cvrepl.self_liked
    }
  }

  const handle_repl_form = (new_repl?: CV.Cvrepl) => {
    show_repl = false
    if (!new_repl) return

    cvrepl.repls ||= []
    cvrepl.repls.unshift(new_repl)
    cvrepl = cvrepl
  }
</script>

<div
  id="rp-{cvrepl.id}"
  class="repl nest_{nest_level % 5}"
  class:nested={nest_level > 0}
  class:on_focus>
  <header class="repl-head">
    <cvrepl-meta>
      <a class="cv-user" href="/@{cvrepl.u_dname}" data-privi={cvrepl.u_privi}
        >{cvrepl.u_dname}
      </a>
    </cvrepl-meta>

    <cvrepl-sep>·</cvrepl-sep>

    <span class="meta">
      {rel_time(cvrepl.ctime)}
      {#if cvrepl.utime > cvrepl.ctime}*{/if}
    </span>
  </header>

  <main class="repl-body m-article">{@html cvrepl.ohtml}</main>

  <footer class="repl-foot">
    <button
      class="meta btn"
      class:_active={show_repl}
      on:click={() => (show_repl = !show_repl)}>
      <SIcon name="arrow-forward" />
      <span>Trả lời</span>
    </button>

    <button
      class="btn"
      class:_active={cvrepl.self_liked}
      disabled={_user.privi < 0}
      on:click={toggle_like}>
      <SIcon name="thumb-up" />
      <span>Ưa thích</span>
      {#if cvrepl.like_count > 0}
        <span class="badge">{cvrepl.like_count}</span>
      {/if}
    </button>
  </footer>
</div>

{#if show_repl}
  <section class="new-repl">
    <CvreplForm
      cvpost_id={cvrepl.post_id}
      dtrepl_id={cvrepl.id}
      disabled={_user.privi < 1}
      on_destroy={handle_repl_form} />
  </section>
{/if}

<style lang="scss">
  .repl {
    margin: 0.75rem 0;
    font-size: rem(17px);

    // border-left: 3px solid var(--bdcolor);
    // padding-left: 0.75rem;

    &.on_focus {
      @include bgcolor(warning, 5, 1);
    }
  }

  .nested {
    border-left: 3px solid var(--bdcolor);
    padding-left: 0.75rem;
    // margin-left: -0.25rem;
  }

  .nest_0 {
    --bdcolor: #{color(neutral, 5, 2)};
  }

  .nest_1 {
    --bdcolor: #{color(primary, 5, 8)};
  }

  .nest_2 {
    --bdcolor: #{color(warning, 5, 8)};
  }

  .nest_3 {
    --bdcolor: #{color(success, 5, 8)};
  }

  .nest_4 {
    --bdcolor: #{color(harmful, 5, 8)};
  }

  .new-repl {
    padding-left: 0.75rem;
  }

  .repl-head {
    @include flex-cy($gap: 0.25rem);
  }

  .repl-body {
    display: block;
    margin: 0.25rem 0;
    word-wrap: break-word;

    font-size: rem(16px);

    // .fluid & {
    //   @include bps(font-size, rem(16px), $tm: rem(17px));
    // }

    > :global(*) + :global(*) {
      margin-top: 1em;
    }

    // > :global(*) {
    //   max-width: 70ch;
    // }
  }

  cvrepl-sep {
    @include flex-ca;
    @include fgcolor(tert);
  }

  .meta {
    display: inline-flex;
    align-items: center;
    gap: 0.125rem;

    @include fgcolor(tert);
    @include ftsize(sm);
  }

  // dthead-right {
  //   @include flex-cy($gap: 0.25rem);
  //   margin-left: auto;
  // }

  .repl-foot {
    margin-top: 0.375rem;
    @include flex-cy($gap: 0.75rem);
  }

  .btn {
    background: none;
    padding: 0;
    @include flex-ca($gap: 0.125rem);
    @include fgcolor(tert);
    @include ftsize(sm);
    @include hover {
      @include fgcolor(primary, 5);
    }

    &._active {
      @include fgcolor(warning, 5);
    }
  }

  // .edit {
  //   font-size: rem(13px);
  //   font-style: italic;
  //   // @include fgcolor(mute);
  // }
</style>
