<script lang="ts">
  import { get_user } from '$lib/stores'

  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import RpnodeForm from './RpnodeForm.svelte'
  import { browser } from '$app/environment'

  export let repl: CV.Rpnode
  export let user: CV.Viuser
  export let memo: CV.Memoir = { liked: 0, track: 0, tagged: 0, viewed: 0 }

  export let on_focus = false
  export let nest_level = 0

  const _user = get_user()

  // $: is_owner = $_user.uname == user.uname
  // $: can_edit = _user.privi > 3 || (is_owner && _user.privi >= 0)

  $: if (browser) on_focus = on_focus || location.hash == '#r' + repl.id
  let show_repl = false

  async function toggle_like() {
    const type = memo?.liked > 0 ? 'unlike' : 'like'
    const api_url = `/_db/memos/rpnode/${repl.id}/${type}`
    const api_res = await fetch(api_url, { method: 'PUT' })

    if (!api_res.ok) {
      alert(await api_res.text())
    } else {
      const { like_count, memo_liked } = await api_res.json()
      repl.like_count = like_count
      memo.liked = memo_liked
    }
  }

  const handle_repl_form = (new_repl?: CV.Rpnode) => {
    show_repl = false
    if (!new_repl) return

    repl.repls ||= []
    repl.repls.unshift(new_repl)
    repl = repl
  }
</script>

<div
  id="r{repl.id}"
  class="repl nest_{nest_level % 5}"
  class:nested={nest_level > 0}
  class:on_focus>
  <header class="repl-head">
    <a class="cv-user _meta" href="/@{user.uname}" data-privi={user.privi}
      >{user.uname}
    </a>

    <span class="fg-tert">&middot;</span>

    <time class="meta">
      {rel_time(repl.ctime)}
      {repl.utime > repl.ctime ? '*' : ''}
    </time>
  </header>

  <main class="repl-body m-article">{@html repl.ohtml}</main>

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
      class:_active={memo?.liked > 0}
      disabled={$_user.privi < 0}
      on:click={toggle_like}>
      <SIcon name="thumb-up" />
      <span>Ưa thích</span>
      {#if repl.like_count > 0}
        <span class="badge">{repl.like_count}</span>
      {/if}
    </button>
  </footer>
</div>

{#if show_repl}
  <section class="new-repl">
    <RpnodeForm
      form={{
        itext: '',
        level: repl.level + 1,
        murepl: 0,
        torepl: repl.id,
        touser: repl.user_id,
        muhead: `id:${repl.head_id}`,
      }}
      disabled={$_user.privi < 0}
      on_destroy={handle_repl_form} />
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

    font-size: rem(16px);

    > :global(*) {
      max-width: 70ch;
    }

    > :global(* + *) {
      margin-top: 1em;
    }
  }

  ._meta {
    @include ftsize(sm);
  }

  .meta {
    display: inline-flex;
    align-items: center;
    gap: 0.125rem;

    @include fgcolor(tert);
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
