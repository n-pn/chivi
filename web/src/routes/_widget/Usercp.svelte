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

  <button slot="header-right" class="-btn" on:click={logout}>
    <SIcon name="log-out" />
  </button>

  <section class="content">
    <header class="label">
      <SIcon name="layers" />
      <span>Tủ truyện</span>
    </header>
    <div class="chips">
      {#each mark_types as mtype}
        <a href="/@{$u_dname}?bmark={mtype}" class="-chip">
          {mark_names[mtype]}
        </a>
      {/each}
    </div>
  </section>

  <section class="content">
    <header class="label">
      <SIcon name="book-open" />
      <span>Lịch sử đọc</span>
    </header>
    <div>Đang hoàn thiện!</div>
  </section>
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
    @include flex();
    // @include label();
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0 -0.5rem;
    margin-bottom: 0.25rem;
    padding: 0 0.5rem;
    text-transform: uppercase;
    @include font-size(2);
    @include fgcolor(neutral, 6);

    :global(svg) {
      margin-top: 0.5rem;
      width: 1.25rem;
      height: 1.25rem;
    }

    span {
      margin-left: 0.5rem;
    }
  }

  .chips {
    @include flow();
    @include props(margin-top, -0.25rem, -0.375rem);
    @include props(margin-left, -0.25rem, -0.375rem);

    @include props(font-size, 11px, 12px, 13px);
    @include props(line-height, 1.25rem, 1.5rem, 1.75rem);
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
      @include bdcolor(primary, 5);
      @include fgcolor(primary, 6);
    }
  }
</style>
