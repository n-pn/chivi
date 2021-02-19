<script>
  import RTime from '$blocks/RTime'

  export let info
</script>

{#if info.uname && info.uname != '_'}
  <div class="edit">
    <span class="-text">{info.state} bởi: </span>
    <span class="-user">{info.uname}</span>
    <span class="-text">Q.hạn:</span>
    <span class="-user">{info.power}</span>
    <span class="-text">Thời gian:</span>
    <span class="-time"><RTime mtime={info.mtime} /></span>
  </div>
{:else}
  <div class="hint" />
{/if}

<style lang="scss">
  .edit {
    text-align: center;
    height: 2rem;

    line-height: 2rem;

    // height: 2.75rem;
    // padding-top: 1px;
    @include fgcolor(neutral, 6);
    @include font-size(1);
  }

  .hint {
    height: 2rem;
  }

  .-text {
    font-style: italic;
  }

  .-time,
  .-user {
    @include fgcolor(primary, 8, 0.7);
    font-weight: 500;
  }

  .-user {
    @include truncate(5vw);
  }
</style>
