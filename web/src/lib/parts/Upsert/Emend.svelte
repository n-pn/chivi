<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'

  export let term
  export let p_min
</script>

<div class="edit">
  <SIcon name="lock" />
  <span class="lbl">Q. hạn:</span>
  <span class="val">{p_min}</span>

  <span class="sep">|</span>
  <SIcon name="users" />

  {#if term._main.uname != '!'}
    <span class="lbl">{term._main.state}</span>
    <span class="val">{get_rtime(term._main.mtime)}</span>
    <span class>bởi</span>
    <span class="val user">{term._main.uname}</span>
  {:else}
    <span>Chưa có lịch sử</span>
  {/if}

  <span class="sep">|</span>
  <SIcon name="user" />

  {#if term._priv.uname != '!'}
    <span>{term._priv.state}:</span>
    <span class="val">{get_rtime(term._priv.mtime)}</span>
  {:else}
    <span>Chưa có lịch sử</span>
  {/if}
</div>

<style lang="scss">
  .edit {
    @include flex($center: both, $gap: 0.2rem);
    margin: 0.5rem 0;
    line-height: 1rem;
    @include ftsize(xs);
    @include fgcolor(tert);

    :global(svg) {
      margin-right: -0.125rem;
    }
  }

  .lbl {
    @include bps(display, none, $sm: inline);
  }

  .val {
    font-weight: 500;
  }

  .user {
    @include clamp(5vw);
  }
</style>
