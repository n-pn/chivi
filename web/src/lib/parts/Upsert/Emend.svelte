<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'

  export let term
  export let p_min

  function render_time(mtime) {
    return get_rtime(mtime * 60 + 1577836800)
  }

  $: console.log(term)
</script>

<div class="edit">
  <SIcon name="lock" />
  <span class="lbl">Q. hạn:</span>
  <span class="val">{p_min}</span>

  <span class="sep">|</span>
  <SIcon name="users" />

  {#if term._raw.p_mtime > 0}
    <span class="lbl">{term._raw.p_state}:</span>
    <span class="val">{render_time(term._raw.p_mtime)}</span>
    <span class>bởi</span>
    <span class="val user">{term._raw.p_uname}</span>
  {:else}
    <span>Chưa có lịch sử</span>
  {/if}

  <span class="sep">|</span>
  <SIcon name="user" />

  {#if term._raw.u_mtime > 0}
    <span>{term._raw.u_state}:</span>
    <span class="val">{render_time(term._raw.u_mtime)}</span>
  {:else}
    <span>Chưa có lịch sử</span>
  {/if}
</div>

<style lang="scss">
  .edit {
    @include flex($center: both, $gap: 0.2rem);
    padding: 0.5rem 0;
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
