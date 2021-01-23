<script>
  import RTime from '$blocks/RTime'

  export let info
  $: _orig = info.vals[0]
  $: _prev = info.hints[0]
  $: state = !_orig ? 'Xoá' : _prev ? 'Sửa' : 'Thêm'
</script>

<div class="emend">
  <div class="-line">
    <span class="-text">{state} bởi: </span>
    <span class="-user">{info.uname}</span>
    <span class="-text">Q.hạn:</span>
    <span class="-user">{info.power}</span>
  </div>

  <div class="-line">
    <span class="-text">Thời gian:</span>
    <span class="-time"><RTime m_time={info.mtime} /></span>
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
