<script lang="ts">
  import { session } from '$app/stores'

  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'
  import DtpostForm from './DtpostForm.svelte'

  export let dtpost: CV.Dtpost
  export let active_card = ''
  export let render_mode = 0

  let card_id = `tp-${dtpost.no}`
  $: is_owner = $session.uname == dtpost.u_dname
  $: can_edit = $session.privi > 3 || (is_owner && $session.privi >= 0)

  let _mode = 0

  let on_destroy = (dirty = false) => {
    if (dirty) window.location.reload()
    else _mode = 0
  }

  $: board_url = `/forum/-${dtpost.db_bslug}`
  $: topic_url = `${board_url}/-${dtpost.dt_tslug}-${dtpost.dt}`
</script>

<dtpost-wrap class:fluid={$$props.fluid}>
  {#if _mode == 1}
    <dtpost-edit>
      <DtpostForm dtopic_id={dtpost.dt} dtpost_id={dtpost.id} {on_destroy} />
    </dtpost-edit>
  {:else}
    <dtpost-card
      id={card_id}
      class:active={active_card == card_id}
      class:larger={render_mode == 0}>
      {#if render_mode > 0}
        <dtpost-orig>
          <SIcon name="messages" />
          <a href={board_url}>{dtpost.db_bname}</a>
          <span>/</span>
          <a href={topic_url}>{dtpost.dt_title}</a>
        </dtpost-orig>
      {/if}

      <dtpost-head>
        <dtpost-meta>
          <a
            class="cv-user"
            href="{topic_url}?op={dtpost.u_dname}"
            data-privi={dtpost.u_privi}
            >{dtpost.u_dname}
          </a>
        </dtpost-meta>

        {#if dtpost.rp_no > 0}
          <dtpost-sep><SIcon name="corner-up-right" /></dtpost-sep>
          <dtpost-meta>
            <a
              class="cv-user"
              href="{topic_url}#tp-{dtpost.rp_no}"
              data-privi={dtpost.ru_privi}
              on:click={() => (active_card = 'tp-' + dtpost.rp_no)}
              >{dtpost.ru_dname}
            </a>
          </dtpost-meta>
        {/if}

        <dtpost-sep>·</dtpost-sep>
        <dtpost-meta>{rel_time(dtpost.ctime)}</dtpost-meta>

        {#if dtpost.utime > dtpost.ctime}
          <dtpost-sep>·</dtpost-sep>
          <dtpost-meta class="edit">Đã sửa</dtpost-meta>
        {/if}

        <dthead-right>
          <button
            class="btn"
            disabled={!can_edit}
            data-tip="Sửa nội dung"
            on:click={() => (_mode = 1)}>
            <SIcon name="pencil" />
          </button>

          <a class="btn" href="{topic_url}#{card_id}">
            <dtpost-meta class="no">#{dtpost.no}</dtpost-meta>
          </a>
        </dthead-right>
      </dtpost-head>

      <dtpost-body class="m-article">{@html dtpost.ohtml}</dtpost-body>

      <dtpost-foot>
        <dtpost-stats>
          {#if dtpost.like_count > 0}
            <dtpost-meta>
              <SIcon name="heart" />
              <span>{dtpost.like_count}</span>
            </dtpost-meta>
          {/if}

          {#if dtpost.repl_count > 0}
            <dtpost-meta>
              <SIcon name="message-circle" />
              <span>{dtpost.repl_count}</span>
            </dtpost-meta>
          {/if}
        </dtpost-stats>

        <dtpost-react>
          <dtpost-meta>
            <button class="btn">
              <span>{dtpost.like_count > 0 ? dtpost.like_count : ''}</span>
              <SIcon name="thumb-up" />
              <span>Thích</span>
            </button>
          </dtpost-meta>

          <dtpost-meta>
            <button class="btn" on:click={() => (_mode = 2)}>
              <SIcon name="arrow-back-up" />
              <span>Trả lời</span>
            </button>
          </dtpost-meta>
        </dtpost-react>
      </dtpost-foot>
    </dtpost-card>
  {/if}

  {#if _mode == 2}
    <dtpost-repl>
      <DtpostForm dtopic_id={dtpost.dt} dtrepl_id={dtpost.id} {on_destroy} />
    </dtpost-repl>
  {/if}
</dtpost-wrap>

<style lang="scss">
  dtpost-wrap {
    display: block;
    @include border($loc: top);
  }

  dtpost-card {
    display: block;

    &.active {
      @include bgcolor(tert);
    }

    &.larger {
      font-size: rem(17px);
    }
  }

  dtpost-edit {
    display: block;
    padding-bottom: 0.75rem;
  }

  dtpost-repl {
    display: block;
    margin-left: var(--gutter);
    @include border($loc: top);
  }

  dtpost-head {
    @include flex-cy($gap: 0.25rem);
    padding-top: 0.25rem;
  }

  dtpost-body {
    display: block;
    margin: 0.25rem 0;
    word-wrap: break-word;

    font-size: rem(16px);

    .fluid & {
      @include bps(font-size, rem(16px), $tm: rem(17px));
    }
  }

  dtpost-sep {
    @include flex-ca;
    @include fgcolor(tert);
  }

  dtpost-meta {
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

  dtpost-foot {
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
  }

  .no {
    letter-spacing: 0.1em;
    font-size: rem(13px);
  }

  .edit {
    font-size: rem(13px);
    font-style: italic;
    // @include fgcolor(mute);
  }

  dtpost-stats,
  dtpost-react {
    @include flex-cy($gap: 0.75rem);
  }

  dtpost-react {
    margin-left: auto;
    padding-right: 0.5rem;
  }

  dtpost-orig {
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
