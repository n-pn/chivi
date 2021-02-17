<script>
  import RTime from '$blocks/RTime'

  export let info
</script>

<div class="emend">
  <div class="-line">
    <span class="-text">{info.state} bởi: </span>
    <span class="-user">{info.uname}</span>
    <span class="-text">Q.hạn:</span>
    <span class="-user">{info.power}</span>
  </div>

  <div class="-line">
    <span class="-text">Thời gian:</span>
    <span class="-time"><RTime mtime={info.mtime} /></span>
  </div>
</div>

<style lang="scss">
  .emend {
    height: 2.75rem;
    line-height: 1.375rem;
    // padding-top: 1px;
    @include fgcolor(neutral, 6);
    @include font-size(2);
  }

  .-text {
    font-style: italic;
  }

  .-time,
  .-user {
    @include fgcolor(primary, 8);
  }

  .-user {
    font-weight: 500;
    @include truncate(5vw);
  }
</style>
