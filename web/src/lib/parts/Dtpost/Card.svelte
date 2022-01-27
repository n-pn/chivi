<script>
  import { session, page } from '$app/stores'

  import { rel_time } from '$lib/utils'
  import { SIcon, Gmenu } from '$lib/components'
  import DtpostForm from './Form.svelte'

  export let dtpost
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
</script>

{#if _mode == 1}
  <dtpost-edit>
    <DtpostForm dtopic_id={dtpost.dt} dtpost_id={dtpost.id} {on_destroy} />
  </dtpost-edit>
{:else}
  <dtpost-item>
    <dtpost-card
      id={card_id}
      class:active={active_card == card_id}
      class:spread={render_mode == 1}>
      <dtpost-head>
        <dtpost-meta>
          <a
            class="cv-user"
            href="{$page.url.pathname}?cvuser={dtpost.u_dname}"
            privi={dtpost.u_privi}
            >{dtpost.u_dname}
          </a>
        </dtpost-meta>

        {#if dtpost.rp_no > 0}
          <dtpost-sep><SIcon name="corner-up-right" /></dtpost-sep>
          <dtpost-meta>
            <a
              class="cv-user"
              href="{$page.url.pathname}#tp-{dtpost.rp_no}"
              privi={dtpost.ru_privi}
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
          <Gmenu dir="right">
            <button class="btn" slot="trigger">
              <dtpost-meta class="no">#{dtpost.no}</dtpost-meta>
            </button>

            <svelte:fragment slot="content">
              <button
                class="-item"
                disabled={!can_edit}
                on:click={() => (_mode = 1)}>
                <SIcon name="pencil" />
                <span>Sửa nội dung</span>
              </button>
            </svelte:fragment>
          </Gmenu>
        </dthead-right>
      </dtpost-head>

      <dtpost-body class="m-article">
        {@html dtpost.ohtml}
      </dtpost-body>

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
  </dtpost-item>
{/if}

{#if _mode == 2}
  <dtpost-repl>
    <DtpostForm dtopic_id={dtpost.dt} dtrepl_id={dtpost.id} {on_destroy} />
  </dtpost-repl>
{/if}

<style lang="scss">
  dtpost-edit {
    display: block;
  }

  dtpost-repl {
    display: block;
    margin-left: 0.75rem;
  }

  dtpost-item {
    display: block;
    margin-top: 0.75rem;
  }

  dtpost-card {
    display: inline-block;
    min-width: min(24rem, 85vw);
    max-width: 100%;

    @include bgcolor(secd);
    @include bdradi();
    @include shadow();

    &.active {
      @include bgcolor(tert);
    }

    &.spread {
      width: 100%;
    }

    @include tm-dark {
      @include linesd(--bd-main);
    }
  }

  dtpost-head {
    @include flex-cy($gap: 0.25rem);
    margin: 0.375rem 0.75rem;
  }

  dtpost-body {
    display: block;
    margin: 0.375rem 0.75rem;
    word-wrap: break-word;
    // font-size: rem(17px);
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
    @include flex-cy;
    margin-left: auto;
  }

  dtpost-foot {
    display: flex;
    margin: 0.375rem 0.75rem;
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
  }
</style>
