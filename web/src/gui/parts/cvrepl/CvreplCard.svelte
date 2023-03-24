<script lang="ts">
  import { session } from '$lib/stores'

  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'
  import CvreplForm from './CvreplForm.svelte'

  export let cvrepl: CV.Cvrepl
  export let active_card = ''
  export let render_mode = 0

  let card_id = `tp-${cvrepl.no}`
  $: is_owner = $session.uname == cvrepl.u_dname
  $: can_edit = $session.privi > 3 || (is_owner && $session.privi >= 0)

  let _mode = 0

  export let on_cvrelp_form = (dirty = false) => {
    if (dirty) window.location.reload()
    else _mode = 0
  }

  $: board_url = `/forum/-${cvrepl.db_bslug}`
  $: topic_url = `${board_url}/-${cvrepl.dt_tslug}-${cvrepl.dt}`

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
</script>

<cvrepl-wrap class:fluid={$$props.fluid}>
  {#if _mode == 1}
    <cvrepl-edit>
      <CvreplForm
        cvpost_id={cvrepl.dt}
        cvrepl_id={cvrepl.id}
        on_destroy={on_cvrelp_form} />
    </cvrepl-edit>
  {:else}
    <cvrepl-card
      id={card_id}
      class:active={active_card == card_id}
      class:larger={render_mode == 0}>
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

        {#if cvrepl.rp_no > 0}
          <cvrepl-sep><SIcon name="corner-up-right" /></cvrepl-sep>
          <cvrepl-meta>
            <a
              class="cv-user"
              href="{topic_url}#tp-{cvrepl.rp_no}"
              data-privi={cvrepl.ru_privi}
              on:click={() => (active_card = 'tp-' + cvrepl.rp_no)}
              >{cvrepl.ru_dname}
            </a>
          </cvrepl-meta>
        {/if}

        <cvrepl-sep>·</cvrepl-sep>
        <cvrepl-meta>{rel_time(cvrepl.ctime)}</cvrepl-meta>

        {#if cvrepl.utime > cvrepl.ctime}
          <cvrepl-sep>·</cvrepl-sep>
          <cvrepl-meta class="edit">Đã sửa</cvrepl-meta>
        {/if}

        <dthead-right>
          <button
            class="btn"
            disabled={!can_edit}
            data-tip="Sửa nội dung"
            on:click={() => (_mode = 1)}>
            <SIcon name="pencil" />
          </button>
        </dthead-right>
      </cvrepl-head>

      <cvrepl-body class="m-article">{@html cvrepl.ohtml}</cvrepl-body>

      <cvrepl-foot>
        <cvrepl-stats>
          {#if cvrepl.like_count > 0}
            <cvrepl-meta>
              <SIcon name="heart" />
              <span>{cvrepl.like_count}</span>
            </cvrepl-meta>
          {/if}

          {#if cvrepl.repl_count > 0}
            <cvrepl-meta>
              <SIcon name="message-circle" />
              <span>{cvrepl.repl_count}</span>
            </cvrepl-meta>
          {/if}
        </cvrepl-stats>

        <cvrepl-react>
          <cvrepl-meta>
            <button
              class="btn"
              class:_active={cvrepl.self_liked}
              disabled={$session.privi < 0}
              on:click={toggle_like}>
              <SIcon name="thumb-up" />
              <span>Thích</span>
            </button>
          </cvrepl-meta>

          <cvrepl-meta>
            <button class="btn" on:click={() => (_mode = 2)}>
              <SIcon name="arrow-back-up" />
              <span>Trả lời</span>
            </button>
          </cvrepl-meta>
        </cvrepl-react>
      </cvrepl-foot>
    </cvrepl-card>
  {/if}

  {#if _mode == 2}
    <cvrepl-repl>
      <CvreplForm
        cvpost_id={cvrepl.dt}
        dtrepl_id={cvrepl.id}
        on_destroy={on_cvrelp_form} />
    </cvrepl-repl>
  {/if}
</cvrepl-wrap>

<style lang="scss">
  cvrepl-wrap {
    display: block;
    @include border($loc: top);
  }

  cvrepl-card {
    display: block;

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
    padding-top: 0.375rem;
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
  }

  cvrepl-sep {
    @include flex-ca;
    @include fgcolor(tert);
  }

  cvrepl-meta {
    display: inline-flex;
    gap: 0.125rem;
    align-items: center;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  dthead-right {
    @include flex-cy($gap: 0.25rem);
    margin-left: auto;
  }

  cvrepl-foot {
    display: flex;
    padding-bottom: 0.25rem;
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

  cvrepl-stats,
  cvrepl-react {
    @include flex-cy($gap: 0.75rem);
  }

  cvrepl-react {
    margin-left: auto;
    padding-right: 0.5rem;
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
</style>
