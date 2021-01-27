<script>
  import { logout_user } from '$api/viuser_api'
  import { u_dname, u_power } from '$src/stores'

  import SIcon from '$blocks/SIcon'
  import Slider from './Slider'

  export let actived = false

  async function logout() {
    $u_dname = 'Khách'
    $u_power = 0
    await logout_user(window.fetch)
  }

  import { mark_types, mark_names } from '$utils/constants'
</script>

<Slider bind:actived width={26}>
  <div slot="header-left" class="-icon">
    <SIcon name="user" />
  </div>
  <div slot="header-left" class="-text">{$u_dname} [{$u_power}]</div>

  <section class="content">
    <header class="label">Tủ truyện</header>
    <div class="chips">
      {#each mark_types as mtype}
        <a href="/@{$u_dname}?bmark={mtype}" class="-chip">
          {mark_names[mtype]}
        </a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">Đọc tiếp</header>
    <div>Đang hoàn thiện!</div>
  </section>

  <div slot="footer" class="logout">
    <a class="-link" href="/api/logout" on:click|preventDefault={logout}>
      <SIcon name="log-out" />
      <span class="-text">Đăng xuất</span>
    </a>
  </div>
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
  }

  .content {
    margin-top: 0.5rem;
    padding: 0 1rem;
  }

  .label {
    // @include label();
    font-weight: 500;
    line-height: 1.75rem;
    margin: 0 -0.5rem;
    margin-bottom: 0.5rem;
    padding: 0 0.5rem;
    text-transform: uppercase;
    @include font-size(2);
    @include fgcolor(neutral, 7);
    @include border($sides: left, $width: 3px, $color: primary, $shade: 5);
  }

  .chips {
    @include flow();
    @include props(margin-top, -0.25rem, -0.375rem);
    @include props(margin-left, -0.25rem, -0.375rem);

    @include props(font-size, 12px, 13px);
    @include props(line-height, 1.5rem, 1.75rem);
  }

  .-chip {
    float: left;
    border-radius: 0.75rem;
    padding: 0 0.75em;
    background-color: #fff;

    @include label();
    @include border();
    @include props(margin-top, 0.25rem, 0.375rem);
    @include props(margin-left, 0.25rem, 0.375rem);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .logout {
    display: block;
    line-height: 2.5rem;
    padding: 1rem;
    text-align: center;

    > .-link {
      display: block;
      @include label();

      // @include bgcolor(neutral, 1);
      @include radius();

      &:hover {
        @include bgcolor(neutral, 1);
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
