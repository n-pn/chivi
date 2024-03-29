<script lang="ts">
  import { browser } from '$app/environment'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import { toggle_like } from '$utils/memo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import GdreplForm from './GdreplForm.svelte'

  export let repl: CV.Gdrepl
  export let gdroot = `id:${repl.gdroot}`
  export let on_focus = false
  export let nest_level = 0

  // $: is_owner = $_user.uname == user.uname
  // $: can_edit = _user.privi > 3 || (is_owner && _user.privi >= 0)

  $: if (browser) on_focus = on_focus || location.hash == '#r' + repl.rp_id
  let show_form = false

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like(
      'gdrepl',
      repl.rp_id,
      repl.me_liked,
      ({ like_count, memo_liked }) => {
        repl.like_count = like_count
        repl.me_liked = memo_liked
      }
    )
  }

  const on_form_destroy = (new_repl?: CV.Gdrepl) => {
    show_form = false
    if (!new_repl) return
    repl.repls.unshift(new_repl)
    repl.repls = repl.repls
  }
</script>

<div
  id="r{repl.rp_id}"
  class="repl nest_{nest_level % 5}"
  class:nested={nest_level > 0}
  class:on_focus>
  <header class="repl-head">
    <a class="cv-user _meta" href="/@{repl.u_uname}" data-privi={repl.u_privi}
      >{repl.u_uname}
    </a>

    <span class="u-fg-tert">&middot;</span>

    <time class="m-meta">
      {rel_time(repl.ctime)}
      {repl.utime > repl.ctime ? '*' : ''}
    </time>
  </header>

  <main class="repl-body m-article">{@html repl.ohtml}</main>

  <footer class="repl-foot">
    <button
      class="m-meta btn"
      class:_active={show_form}
      on:click={() => (show_form = !show_form)}>
      <SIcon name="arrow-forward" />
      <span>Trả lời</span>
    </button>

    <button
      class="btn"
      class:_active={repl.me_liked > 0}
      disabled={$_user.privi < 0}
      on:click={handle_like}>
      <SIcon name="thumb-up" />
      <span>Ưa thích</span>
      {#if repl.like_count > 0}
        <span class="m-badge">{repl.like_count}</span>
      {/if}
    </button>
  </footer>
</div>

{#if show_form}
  <section class="new-repl">
    <GdreplForm
      form={{
        itext: '',
        level: repl.level + 1,
        gdrepl: 0,
        torepl: repl.rp_id,
        touser: repl.user_id,
        gdroot,
      }}
      disabled={$_user.privi < 0}
      on_destroy={on_form_destroy} />
  </section>
{/if}

<style lang="scss">
  .repl {
    margin: 0.75rem -0.5rem;
    padding: 0.25rem 0.5rem;
    font-size: rem(17px);

    &.on_focus {
      @include bgcolor(warning, 5, 0.75);
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

    @include bps(font-size, rem(15px), $pl: rem(16px), $tl: rem(17px));

    > :global(* + *) {
      margin-top: 1em;
    }
  }

  ._meta {
    @include ftsize(sm);
  }

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
