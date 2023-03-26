<script lang="ts">
  import { page } from '$app/stores'

  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'
  import CvreplForm from './CvreplForm.svelte'

  export let cvrepl: CV.Cvrepl
  export let render_mode = 0

  export let nest_level = 0

  let card_id = `tp-${cvrepl.no}`

  $: _user = $page.data._user
  $: is_owner = _user.uname == cvrepl.u_dname
  $: can_edit = _user.privi > 3 || (is_owner && _user.privi >= 0)

  $: board_url = `/forum/-${cvrepl.db_bslug}`
  $: topic_url = `${board_url}/-${cvrepl.dt_tslug}-${cvrepl.dt}`

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
    cvrepl.repls.unshift(new_repl)
    cvrepl = cvrepl
    show_repl = false
  }
</script>

<cvrepl-card
  id={card_id}
  class="nest_{nest_level % 5}"
  class:larger={render_mode == 0}
  class:nested={nest_level > 0}>
  {#if render_mode > 0}
    <cvrepl-orig>
      <SIcon name="messages" />
      <a href={board_url}>{cvrepl.db_bname}</a>
      <span>/</span>
      <a href={topic_url}>{cvrepl.dt_title}</a>
    </cvrepl-orig>
  {/if}

  <cvrepl-head>
    <cvrepl-meta>
      <a
        class="cv-user"
        href="{topic_url}?op={cvrepl.u_dname}"
        data-privi={cvrepl.u_privi}
        >{cvrepl.u_dname}
      </a>
    </cvrepl-meta>

    <cvrepl-sep>·</cvrepl-sep>

    <span class="meta">
      {rel_time(cvrepl.ctime)}
      {#if cvrepl.utime > cvrepl.ctime}*{/if}
    </span>
  </cvrepl-head>

  <cvrepl-body class="m-article">{@html cvrepl.ohtml}</cvrepl-body>

  <cvrepl-foot>
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
  </cvrepl-foot>
</cvrepl-card>

{#if show_repl}
  <CvreplForm
    cvpost_id={cvrepl.dt}
    on_destroy={handle_repl_form}
    disabled={_user.privi < 1} />
{/if}

<style lang="scss">
  cvrepl-card {
    display: block;
    margin: 0.75rem 0;

    &.active {
      @include bgcolor(tert);
    }

    &.larger {
      font-size: rem(17px);
    }
  }

  cvrepl-edit {
    display: block;
    padding-bottom: 0.75rem;
  }

  cvrepl-repl {
    display: block;
    margin-left: var(--gutter);
    @include border($loc: top);
  }

  cvrepl-head {
    @include flex-cy($gap: 0.25rem);
  }

  cvrepl-body {
    display: block;
    margin: 0.25rem 0;
    word-wrap: break-word;

    font-size: rem(16px);

    .fluid & {
      @include bps(font-size, rem(16px), $tm: rem(17px));
    }

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

  dthead-right {
    @include flex-cy($gap: 0.25rem);
    margin-left: auto;
  }

  cvrepl-foot {
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

  .edit {
    font-size: rem(13px);
    font-style: italic;
    // @include fgcolor(mute);
  }

  cvrepl-orig {
    @include flex-cy($gap: 0.125rem);
    @include ftsize(xs);
    line-height: 1.25rem;

    @include border($loc: top-bottom);
    @include fgcolor(tert);

    a {
      color: inherit;
      @include clamp($width: null);
    }

    a:hover {
      @include fgcolor(primary, 5);
    }
  }

  .nested {
    --bdcolor: #{color(neutral, 5, 3)};

    border-left: 3px solid var(--bdcolor);
    padding-left: 0.75rem;
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
</style>
